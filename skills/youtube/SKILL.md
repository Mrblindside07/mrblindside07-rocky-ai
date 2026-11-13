---
name: youtube
description: Use when the user shares a youtube.com or youtu.be URL, asks to watch, analyze, summarize, review, or extract code/slides/transcripts from a YouTube video, or triggers /youtube. Extracts full metadata, timestamped subtitles/CC, and visual keyframes so the AI can both read the transcript and visually inspect the video frames.
argument-hint: <youtube-url> [--no-frames] [--max-frames 12]
---

## What This Skill Does

Allows the AI agent to **watch and analyze any YouTube video** end-to-end by combining:
1. **Metadata & Chapters** (`title`, `channel`, `duration`, `description`, `chapters`) via `yt-dlp`.
2. **Clean Timestamped Transcript** (manual or auto-generated subtitles in Indonesian/English) converted from VTT into readable `[MM:SS]` paragraphs.
3. **Visual Keyframes Extraction** (`ffmpeg` + `yt-dlp` at 720p) saved as `.jpg` images so the AI can inspect slides, code editors, diagrams, and facecam using `read_file`.

## Context

- Inspector script: `~/.gemini/config/skills/youtube/yt-inspect.js` (Windows: `C:\Users\mrblindside07\.gemini\config\skills\youtube\yt-inspect.js`)
- Output directory: `os.tmpdir()/agy-youtube/<video-id>/` (`%TEMP%\agy-youtube\<video-id>\` on Windows, `/tmp/agy-youtube/<video-id>/` on Linux) containing `report.md`, `metadata.json`, and `frames/frame_XX.jpg`
- Dependencies: Node.js, `yt-dlp`, `ffmpeg` (auto-detected from PATH, `/usr/bin`, or WinGet Packages)

## Steps

1. **Run the YouTube Inspector Script**
   Execute the script against the user's YouTube URL:
   ```bash
   node "$HOME/.gemini/config/skills/youtube/yt-inspect.js" "<YOUTUBE_URL>" --max-frames 10
   ```
   *(On Windows PowerShell use `"$env:USERPROFILE\.gemini\config\skills\youtube\yt-inspect.js"`. Add `--no-frames` for faster text-only summaries).*

2. **Read the Generated Report (`report.md`)**
   Use `read_file` on the `report.md` path printed by the script to read the video metadata, description, chapters, and full timestamped transcript.

3. **Inspect Visual Frames (`frames/frame_XX.jpg`)**
   Use `read_file` on key frame `.jpg` paths listed in the output (e.g., 3–6 representative frames or specific timestamps mentioned in the transcript) so you can see the actual slides, code, terminal output, or UI shown in the video.

4. **Synthesize & Deliver Response**
   Provide a structured response tailored to the user's goal:
   - **Ringkasan Eksekutif**: Inti pembahasan video dalam poin-poin singkat.
   - **Breakdown per Timestamp**: Poin penting + kode/slide yang tampil di layar pada menit terkait.
   - **Catatan / Action Items**: Jika video adalah tugas kuliah, tutorial coding, atau referensi proyek, berikan kesimpulan yang langsung bisa dieksekusi.

## Notes

- Works on both Public and Unlisted (`Tidak Publik`) YouTube videos.
- If a video has no subtitles/CC enabled, rely on the visual keyframes (`frames/*.jpg`) + audio transcription if needed.
- Never commit temporary video files to the project git repository (`%TEMP%\agy-youtube\` is used by default to keep the workspace clean).
