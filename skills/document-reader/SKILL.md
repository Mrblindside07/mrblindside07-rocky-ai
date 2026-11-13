---
name: document-reader
description: Use when someone asks to read, parse, or extract text from PDF, Word (.docx), Excel (.xlsx), PowerPoint (.pptx), HTML, or text files.
argument-hint: "[file path] [--pages 1-5] [--search keyword]"
disable-model-invocation: true
allowed-tools: [Read, Bash, Glob]
---

## What This Skill Does

Reads document files (PDF, Word, Excel, PowerPoint, HTML, TXT) and outputs their text content to the terminal. Supports page ranges for PDFs, specific sheets for Excel, keyword search across documents, and output length limits.

## Files & Dependencies

- **Script:** `read_doc.py` — Python script that handles document parsing
- **Runtime:** `uv` (`uv run` via PATH or `~/.local/bin/uv`)
- **Packages:** `pypdf`, `python-docx`, `openpyxl`, `python-pptx`, `beautifulsoup4` (installed via `uv run`)

## Usage

```
/document-reader [file_path] [options]
```

**Arguments:**
- `file_path` — Path to the document file (absolute or relative)

**Options:**
- `--pages N` — Extract specific page(s) from PDF (e.g. `--pages 3` or `--pages 1-5`)
- `--sheet NAME` — Extract specific sheet from Excel file
- `--search KEYWORD` — Search for keyword within document (case-insensitive)
- `--max-chars N` — Limit output length (default: 50000)

## Steps

1. **Validate input:** Check that the file exists at the given path. Exit with error if not found.
2. **Detect file type:** Determine parsing method based on file extension (`.pdf`, `.docx`, `.xlsx`, `.pptx`, `.html`, `.txt`).
3. **Execute Python script:**
   ```bash
   uv run --with pypdf --with python-docx --with openpyxl --with python-pptx --with beautifulsoup4 python /path/to/read_doc.py <file_path> [options]
   ```
4. **Output results:** Document text is printed to stdout with section markers:
   - `=== Document Header ===` — Shows file type and metadata
   - `--- Page X ---` — Page/section breaks (PDF, PPTX)
   - `--- Sheet: NAME ---` — Excel sheet separators
   - `--- Slide N ---` — PowerPoint slide separators
   - `[Notes]:` — Speaker notes (PPTX)

## Output Format

All output goes to stdout (terminal). Structure varies by document type:

- **PDF:** `=== PDF Document (N pages) ===` followed by `--- Page N ---` sections
- **DOCX:** `=== Word Document ===` with markdown-style headings (`##`, `###`) and table output in Markdown table format
- **XLSX:** `=== Excel Workbook ===` with `--- Sheet: NAME ---` for each sheet, rows as `| col1 | col2 |`
- **PPTX:** `=== PowerPoint Presentation (N slides) ===` with text and speaker notes
- **HTML:** `=== HTML Document ===` with extracted text (tags stripped, newlines preserved)
- **TXT:** `=== Plain Text File ===` with raw content

## Examples

```bash
/document-reader "./data/report.pdf"
/document-reader "./data/report.pdf" --pages 1-3
/document-reader "./notes.docx"
/document-reader "./budget.xlsx" --sheet "Q4"
/document-reader "./presentation.pptx"
/document-reader "./data/report.pdf" --search "budget"
/document-reader "./data/huge.pdf" --max-chars 5000
/file.pdf --search "keyword"
```

## Notes

- Uses `uv` for isolated dependency resolution — packages are fetched fresh each run (no global install needed)
- Windows console is configured for UTF-8 output
- CSV files are parsed using `openpyxl` (Excel backend)
- `.doc` and `.xls` (legacy formats) fall back to the docx/xlsx readers; if they fail, use a conversion tool first
- Text extraction from PDFs is handled by `pypdf` — quality depends on whether the PDF was created with a text layer (scanned PDFs may need OCR)
- Output truncation via `--max-chars` ensures very large files don't overwhelm the context
- Script outputs to stdout only — no files are written

## Related Skills

- `quiz-auto` — Reads Google Drive PDFs and extracts content for auto-answering forms
- `site-cloner` — Clones website content (HTML pages)
