---
name: gdrive-video
description: Use when the user provides a Google Drive link to a video, lecture recording, or audio file, and wants it downloaded, opened, or summarized. Handles Google Drive file ID extraction, automated high-speed download via gdown (supporting large files, virus scan bypass, and browser cookies), and optional lecture summarization with Gemini.
argument-hint: <gdrive-url> [--summarize]
---

# Google Drive Video & Lecture Processor

## Purpose
Enables Antigravity to download, open, and summarize videos or audio recordings hosted on Google Drive.

## Workflow

### Step 1: Download from Google Drive
Run the dedicated downloader:
```bash
& 'C:\Users\mrblindside07\.local\bin\uv.exe' run 'D:\download\download_gdrive.py' "<GOOGLE_DRIVE_URL>"
```
* Saves by default into: `D:\Kuliah_Recordings\`
* Handles `file/d/[ID]/view`, `open?id=[ID]`, and fuzzy Google Drive links.
* If the file is private to student's UKSW/University account, add `--browser chrome` to use authenticated session cookies.

### Step 2: Summarize (If requested)
Once the file path is confirmed:
```bash
& 'C:\Users\mrblindside07\.local\bin\uv.exe' run 'D:\download\summarize_lecture.py' --file "<DOWNLOADED_FILE_PATH>"
```
The summary will be generated as a clean Markdown note alongside the video.
