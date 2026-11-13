#!/usr/bin/env node
/**
 * YouTube Inspector & Visual Frame Extractor
 * Extracts metadata, clean timestamped transcripts (CC/auto-subs), and visual keyframes
 * so the AI agent can both read and visually see any YouTube video.
 */

const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

function findBinary(name) {
    if (process.platform !== "win32") {
        try {
            const whichOut = execFileSync("which", [name], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] })
                .trim()
                .split(/\r?\n/)[0];
            if (whichOut && fs.existsSync(whichOut)) return whichOut;
        } catch (_) {}
        const commonPaths = [
            `/usr/bin/${name}`,
            `/usr/local/bin/${name}`,
            path.join(os.homedir(), ".local", "bin", name),
        ];
        for (const p of commonPaths) {
            if (fs.existsSync(p)) return p;
        }
        return name;
    }

    // 1. Check PATH first (Windows)
    try {
        const whereOut = execFileSync("where.exe", [name], { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] })
            .trim()
            .split(/\r?\n/)[0];
        if (whereOut && fs.existsSync(whereOut)) return whereOut;
    } catch (_) {}

    // 2. Check WinGet Links & Packages
    const localAppData = process.env.LOCALAPPDATA || path.join(os.homedir(), "AppData", "Local");
    const wingetLink = path.join(localAppData, "Microsoft", "WinGet", "Links", `${name}.exe`);
    if (fs.existsSync(wingetLink)) return wingetLink;

    const wingetPkgDir = path.join(localAppData, "Microsoft", "WinGet", "Packages");
    if (fs.existsSync(wingetPkgDir)) {
        const pkgs = fs.readdirSync(wingetPkgDir);
        for (const pkg of pkgs) {
            const fullPkg = path.join(wingetPkgDir, pkg);
            const found = walkFind(fullPkg, `${name}.exe`, 3);
            if (found) return found;
        }
    }
    return `${name}.exe`;
}

function walkFind(dir, targetFile, maxDepth, depth = 0) {
    if (depth > maxDepth || !fs.existsSync(dir)) return null;
    try {
        for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
            const full = path.join(dir, entry.name);
            if (entry.isFile() && entry.name.toLowerCase() === targetFile.toLowerCase()) {
                return full;
            }
            if (entry.isDirectory()) {
                const sub = walkFind(full, targetFile, maxDepth, depth + 1);
                if (sub) return sub;
            }
        }
    } catch (_) {}
    return null;
}

function parseVttToCleanText(vttContent) {
    const lines = vttContent.split(/\r?\n/);
    const entries = [];
    let currentTime = "00:00";
    let lastText = "";

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].trim();
        if (
            !line ||
            line === "WEBVTT" ||
            line.startsWith("Kind:") ||
            line.startsWith("Language:") ||
            line.startsWith("NOTE") ||
            /^\d+$/.test(line)
        ) {
            continue;
        }

        const timeMatch = line.match(/^(\d{2}:)?(\d{2}:\d{2})\.\d{3}\s*-->/);
        if (timeMatch) {
            const hrs = timeMatch[1] ? timeMatch[1] : "";
            currentTime = hrs === "00:" ? timeMatch[2] : `${hrs}${timeMatch[2]}`;
            continue;
        }

        const cleaned = line
            .replace(/<[^>]+>/g, "")
            .replace(/&nbsp;/g, " ")
            .replace(/&amp;/g, "&")
            .replace(/&lt;/g, "<")
            .replace(/&gt;/g, ">")
            .replace(/&#39;/g, "'")
            .replace(/&quot;/g, '"')
            .trim();

        if (!cleaned || cleaned === lastText) continue;
        // Skip if previous line already ends with or contains this partial rolling caption
        if (lastText && lastText.includes(cleaned)) continue;
        if (entries.length > 0 && cleaned.startsWith(lastText)) {
            entries[entries.length - 1].text = cleaned;
            lastText = cleaned;
            continue;
        }

        entries.push({ time: currentTime, text: cleaned });
        lastText = cleaned;
    }

    // Group into readable chunks every ~8 entries
    const grouped = [];
    for (let i = 0; i < entries.length; i += 8) {
        const slice = entries.slice(i, i + 8);
        const startTime = slice[0].time;
        const combined = slice.map((e) => e.text).join(" ");
        grouped.push(`[${startTime}] ${combined}`);
    }
    return grouped.join("\n\n");
}

function parseArgs() {
    const args = process.argv.slice(2);
    let url = null;
    let extractFrames = true;
    let maxFrames = 12;
    let outDir = null;

    for (let i = 0; i < args.length; i++) {
        const arg = args[i];
        if (arg === "--no-frames") {
            extractFrames = false;
        } else if (arg === "--max-frames" && args[i + 1]) {
            maxFrames = parseInt(args[++i], 10) || 12;
        } else if (arg === "--out" && args[i + 1]) {
            outDir = args[++i];
        } else if (!arg.startsWith("--") && !url) {
            url = arg;
        }
    }
    return { url, extractFrames, maxFrames, outDir };
}

function main() {
    const { url, extractFrames, maxFrames, outDir } = parseArgs();
    if (!url) {
        console.error("Usage: node yt-inspect.js <youtube-url> [--no-frames] [--max-frames 12] [--out <dir>]");
        process.exit(1);
    }

    const ytDlp = findBinary("yt-dlp");
    const ffmpeg = findBinary("ffmpeg");

    console.log(`[1/4] Fetching metadata using: ${ytDlp}`);
    const rawJson = execFileSync(ytDlp, ["--js-runtimes", "node", "--dump-single-json", "--no-warnings", "--no-playlist", url], {
        encoding: "utf8",
        maxBuffer: 50 * 1024 * 1024,
    });
    const info = JSON.parse(rawJson);
    const videoId = info.id || "video";
    const baseOut = outDir
        ? path.resolve(outDir)
        : path.join(os.tmpdir(), "agy-youtube", videoId);

    fs.mkdirSync(baseOut, { recursive: true });

    const metaSummary = {
        id: info.id,
        title: info.title,
        channel: info.uploader || info.channel,
        duration_seconds: info.duration,
        duration_string: info.duration_string,
        upload_date: info.upload_date,
        view_count: info.view_count,
        webpage_url: info.webpage_url || url,
        description: info.description || "",
        chapters: info.chapters || [],
        output_dir: baseOut,
    };

    // 2. Download subtitles (manual or auto-generated, prioritizing id and en)
    console.log(`[2/4] Extracting subtitles/transcript...`);
    try {
        execFileSync(
            ytDlp,
            [
                "--js-runtimes",
                "node",
                "--skip-download",
                "--write-subs",
                "--write-auto-subs",
                "--sub-langs",
                "id,en,id-*,en-*",
                "--sub-format",
                "vtt",
                "--output",
                path.join(baseOut, "sub"),
                "--no-playlist",
                url,
            ],
            { stdio: "ignore" }
        );
    } catch (_) {}

    const vttFiles = fs.readdirSync(baseOut).filter((f) => f.endsWith(".vtt"));
    let transcriptText = "Tidak ada subtitle/CC pada video ini.";
    let chosenVtt = null;

    if (vttFiles.length > 0) {
        // Prefer Indonesian first, then English
        chosenVtt =
            vttFiles.find((f) => f.includes(".id")) ||
            vttFiles.find((f) => f.includes(".en")) ||
            vttFiles[0];
        const rawVtt = fs.readFileSync(path.join(baseOut, chosenVtt), "utf8");
        transcriptText = parseVttToCleanText(rawVtt);
    }

    const reportPath = path.join(baseOut, "report.md");
    const framesDir = path.join(baseOut, "frames");
    let extractedFrames = [];

    // 3. Extract visual frames if requested
    if (extractFrames) {
        console.log(`[3/4] Downloading lightweight video stream & extracting up to ${maxFrames} visual keyframes...`);
        fs.mkdirSync(framesDir, { recursive: true });
        // Clean old frames
        for (const f of fs.readdirSync(framesDir)) {
            fs.unlinkSync(path.join(framesDir, f));
        }

        const videoPath = path.join(baseOut, "video.mp4");
        if (!fs.existsSync(videoPath)) {
            execFileSync(
                ytDlp,
                [
                    "--js-runtimes",
                    "node",
                    "-f",
                    "bestvideo[height<=720][ext=mp4]/best[height<=720][ext=mp4]/best[height<=720]",
                    "--output",
                    videoPath,
                    "--no-playlist",
                    url,
                ],
                { stdio: "ignore" }
            );
        }

        if (fs.existsSync(videoPath)) {
            const duration = Math.max(info.duration || 60, 5);
            const interval = Math.max(Math.floor(duration / maxFrames), 2);
            execFileSync(
                ffmpeg,
                [
                    "-y",
                    "-i",
                    videoPath,
                    "-vf",
                    `fps=1/${interval},scale=1280:-1`,
                    "-frames:v",
                    String(maxFrames),
                    "-q:v",
                    "3",
                    path.join(framesDir, "frame_%02d.jpg"),
                ],
                { stdio: "ignore" }
            );

            extractedFrames = fs
                .readdirSync(framesDir)
                .filter((f) => f.endsWith(".jpg"))
                .sort()
                .map((f, idx) => {
                    const sec = idx * interval;
                    const mm = String(Math.floor(sec / 60)).padStart(2, "0");
                    const ss = String(sec % 60).padStart(2, "0");
                    return {
                        timestamp: `${mm}:${ss}`,
                        path: path.join(framesDir, f),
                    };
                });
        }
    } else {
        console.log(`[3/4] Skipping visual frame extraction (--no-frames).`);
    }

    // 4. Write complete Markdown report
    console.log(`[4/4] Writing report to: ${reportPath}`);
    const chaptersMd =
        metaSummary.chapters.length > 0
            ? metaSummary.chapters
                  .map((c) => `- **${Math.floor(c.start_time / 60)}m${Math.floor(c.start_time % 60)}s**: ${c.title}`)
                  .join("\n")
            : "_Tidak ada chapter_";

    const framesMd =
        extractedFrames.length > 0
            ? extractedFrames.map((f) => `- [${f.timestamp}] \`${f.path}\``).join("\n")
            : "_Frame tidak diekstrak_";

    const reportMd = `# YouTube Video Report: ${metaSummary.title}

- **Channel:** ${metaSummary.channel}
- **URL:** ${metaSummary.webpage_url}
- **Durasi:** ${metaSummary.duration_string || metaSummary.duration_seconds + "s"}
- **Views:** ${metaSummary.view_count ?? "-"}
- **Tanggal Upload:** ${metaSummary.upload_date ?? "-"}
- **Subtitle File:** ${chosenVtt ?? "None"}

## Deskripsi Video
\`\`\`text
${metaSummary.description}
\`\`\`

## Chapters
${chaptersMd}

## Extracted Visual Frames (${extractedFrames.length} frames)
${framesMd}

## Transcript (Timestamped)
${transcriptText}
`;

    fs.writeFileSync(reportPath, reportMd, "utf8");
    fs.writeFileSync(path.join(baseOut, "metadata.json"), JSON.stringify({ ...metaSummary, extractedFrames }, null, 2), "utf8");

    console.log("\n=== YOUTUBE INSPECTION COMPLETE ===");
    console.log(`Title       : ${metaSummary.title}`);
    console.log(`Channel     : ${metaSummary.channel}`);
    console.log(`Duration    : ${metaSummary.duration_string}`);
    console.log(`Report File : ${reportPath}`);
    console.log(`Frames Count: ${extractedFrames.length}`);
    for (const f of extractedFrames) {
        console.log(`  Frame [${f.timestamp}] -> ${f.path}`);
    }
}

main();
