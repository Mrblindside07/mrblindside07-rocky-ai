# âš¡ mrblindside07-rocky-ai

> **Unified, Live-Sync AI Assistant Configuration & Skill Arsenal**  
> Seamlessly integrated across **Windows (PC)** and **Arch Linux (Laptop)** for Google Antigravity, Claude Code, and Gemini CLI.

---

## ðŸŒŸ Fitur Utama
- **46 Curated High-Impact Skills:** UI/UX (Emil Kowalski, Tailwind, shadcn), Web Performance (Lighthouse >= 90), Playwright Testing, Social Media & Content Automation.
- **Native Live-Sync (Symlink Architecture):** Cukup `git pull`, semua skill dan prompt langsung ter-update di Antigravity tanpa copy-paste manual.
- **Cross-Platform Out of the Box:** Otomatis menyesuaikan path Windows (`C:\...`) dan Linux (`$HOME`).
- **Lean Token Budget:** Deskripsi teroptimasi, token budget terpakai hanya ~20% (sisa 80% sangat lega untuk coding).
- **MCP Server Suite:** Chrome DevTools, Filesystem, Memory, Puppeteer, YouTube Transcript, & Notion preconfigured.

---

## ðŸ’» Cara Install di Windows (PC)

Jalankan PowerShell as Administrator di folder ini:
```powershell
.\setup-windows.ps1
```

---

## ðŸ§ Cara Install di Arch Linux (Laptop)

Clone repositori ini di Arch Linux:
```bash
git clone https://github.com/Mrblindside07/mrblindside07-rocky-ai.git ~/mrblindside07-rocky-ai
cd ~/mrblindside07-rocky-ai
chmod +x setup-linux.sh sync.sh
./setup-linux.sh
```

---

## ðŸ”„ Cara Sinkronisasi Harian (Windows â†” Linux)

### Saat kamu update skill di PC (Windows):
```powershell
.\sync.ps1 -Action push -Message "Tambahkan skill baru / update prompt"
```

### Saat kamu buka Laptop (Arch Linux):
```bash
./sync.sh pull
```
*Seketika itu juga Antigravity & Claude Code di laptopmu langsung ter-update dengan skill terbaru!* ðŸš€
