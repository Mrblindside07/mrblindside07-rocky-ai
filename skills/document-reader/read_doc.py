import sys
import os
import argparse
import json

# Fix Windows console UTF-8 output
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8')
    sys.stderr.reconfigure(encoding='utf-8')

def read_pdf(file_path, pages=None):
    import pypdf
    reader = pypdf.PdfReader(file_path)
    total_pages = len(reader.pages)
    output = [f"=== PDF Document ({total_pages} pages) ==="]

    start_page = 0
    end_page = total_pages

    if pages:
        if "-" in pages:
            parts = pages.split("-")
            start_page = max(0, int(parts[0]) - 1) if parts[0] else 0
            end_page = min(total_pages, int(parts[1])) if parts[1] else total_pages
        else:
            start_page = max(0, int(pages) - 1)
            end_page = min(total_pages, start_page + 1)

    for i in range(start_page, end_page):
        page = reader.pages[i]
        text = page.extract_text() or ""
        output.append(f"\n--- Page {i + 1} ---")
        output.append(text.strip())

    return "\n".join(output)

def read_docx(file_path):
    import docx
    doc = docx.Document(file_path)
    output = ["=== Word Document (.docx) ==="]

    # Extract paragraphs and headings
    for p in doc.paragraphs:
        if not p.text.strip():
            continue
        if p.style.name.startswith("Heading"):
            level = p.style.name.replace("Heading", "").strip()
            hashes = "#" * (int(level) if level.isdigit() else 2)
            output.append(f"\n{hashes} {p.text.strip()}")
        else:
            output.append(p.text)

    # Extract tables
    if doc.tables:
        output.append("\n=== Tables ===")
        for t_idx, table in enumerate(doc.tables, 1):
            output.append(f"\n--- Table {t_idx} ---")
            for row in table.rows:
                row_cells = [cell.text.strip().replace("\n", " ") for cell in row.cells]
                output.append("| " + " | ".join(row_cells) + " |")

    return "\n".join(output)

def read_xlsx(file_path, sheet_name=None):
    import openpyxl
    wb = openpyxl.load_workbook(file_path, data_only=True)
    sheets = wb.sheetnames
    output = [f"=== Excel Workbook (Sheets: {', '.join(sheets)}) ==="]

    target_sheets = [sheet_name] if sheet_name and sheet_name in sheets else sheets

    for s_name in target_sheets:
        sheet = wb[s_name]
        output.append(f"\n--- Sheet: {s_name} (Rows: {sheet.max_row}, Cols: {sheet.max_column}) ---")
        for row in sheet.iter_rows(values_only=True):
            if any(cell is not None for cell in row):
                row_str = " | ".join([str(c) if c is not None else "" for c in row])
                output.append("| " + row_str + " |")

    return "\n".join(output)

def read_pptx(file_path):
    import pptx
    prs = pptx.Presentation(file_path)
    output = [f"=== PowerPoint Presentation ({len(prs.slides)} slides) ==="]

    for idx, slide in enumerate(prs.slides, 1):
        output.append(f"\n--- Slide {idx} ---")
        for shape in slide.shapes:
            if hasattr(shape, "text") and shape.text.strip():
                output.append(shape.text.strip())
        if slide.has_notes_slide and slide.notes_slide.notes_text_frame:
            notes = slide.notes_slide.notes_text_frame.text.strip()
            if notes:
                output.append(f"[Notes]: {notes}")

    return "\n".join(output)

def read_html(file_path):
    from bs4 import BeautifulSoup
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        soup = BeautifulSoup(f.read(), "html.parser")
    return f"=== HTML Document ===\n\n" + soup.get_text(separator="\n", strip=True)

def read_text(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()
    return f"=== Plain Text File ({file_path}) ===\n\n" + content

def main():
    parser = argparse.ArgumentParser(description="Read and parse document files (PDF, DOCX, XLSX, PPTX, HTML, TXT)")
    parser.add_argument("file_path", help="Path to document file")
    parser.add_argument("--pages", help="Page range for PDF (e.g. 1-5 or 3)")
    parser.add_argument("--sheet", help="Specific sheet name for Excel")
    parser.add_argument("--search", help="Search keyword inside document")
    parser.add_argument("--max-chars", type=int, default=50000, help="Max output character length")

    args = parser.parse_args()
    file_path = os.path.abspath(args.file_path)

    if not os.path.exists(file_path):
        print(f"Error: File not found at '{file_path}'", file=sys.stderr)
        sys.exit(1)

    ext = os.path.splitext(file_path)[1].lower()

    try:
        if ext == ".pdf":
            text = read_pdf(file_path, args.pages)
        elif ext in [".docx", ".doc"]:
            text = read_docx(file_path)
        elif ext in [".xlsx", ".xls", ".csv"]:
            text = read_xlsx(file_path, args.sheet)
        elif ext in [".pptx", ".ppt"]:
            text = read_pptx(file_path)
        elif ext in [".html", ".htm"]:
            text = read_html(file_path)
        else:
            text = read_text(file_path)

        if args.search:
            lines = text.split("\n")
            matches = [line for line in lines if args.search.lower() in line.lower()]
            text = f"=== Search Results for '{args.search}' in {os.path.basename(file_path)} ({len(matches)} matches) ===\n\n" + "\n".join(matches)

        if len(text) > args.max_chars:
            text = text[:args.max_chars] + f"\n\n... [Truncated: output exceeded {args.max_chars} characters]"

        print(text)

    except Exception as e:
        print(f"Error reading file '{file_path}': {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
