# ⚡ mrblindside07-rocky-ai

> **Rocky AI — Misael's Personal Assistant & IT Consultant (Patrick Jane Persona)**  
> Unified, live-sync configuration & skill arsenal across **Windows (PC)** and **Fedora Linux (Laptop)** for Google Antigravity, Claude Code, and Gemini CLI.

---

## 🌟 Fitur Utama
- **Patrick Jane IT Consultant Persona:** Observant cold-reading of code & bugs, disarming charm & wit, Socratic precision, anti-bloat simplicity, and surgical execution.
- **31 Curated High-Impact Skills:**
  - **UI/UX & Design:** `ui-ux-pro-max`, `frontend-design`, `emil-design-eng`, `ui-styling`, `design`, `design-system`, `slides`, `brand`, `video-to-website`
  - **Testing & Automation:** `playwright`, `cross-browser-check`, `url-screenshot`, `site-cloner`, `deploy`
  - **Workflow & Thinking:** `daily-priorities`, `grill-me`, `git-command`, `claude-coach`, `new-project`, `session-memory`, `level-up`, `agent-builder`, `skill-builder`, `onboard`
  - **Academic & Media Analysis:** `teaching-slides`, `quiz-auto`, `document-reader`, `youtube`, `remotion-best-practices`
- **Native Live-Sync (Symlink / Junction Architecture):** Cukup `git pull` / `./sync.sh pull`, semua skill, global rules (`GEMINI.md` / `CLAUDE.md`), context, dan memory langsung aktif di Antigravity & Claude Code tanpa copy-paste manual.
- **Cross-Platform Out of the Box:** Mendukung Windows (`Junction` + PowerShell) dan Linux (`dnf` Fedora, `pacman` Arch, `apt` Debian/Ubuntu).

---

## 💻 Cara Install di Windows (PC)

Jalankan PowerShell di folder ini:
```powershell
.\setup-windows.ps1
```

---

## 🎩 Cara Install di Fedora Linux (Laptop)

Clone repositori ini dan jalankan installer (otomatis mendeteksi `dnf`, membuat live symlink ke `~/.gemini/config` & `~/.claude`):
```bash
git clone https://github.com/Mrblindside07/mrblindside07-rocky-ai.git ~/mrblindside07-rocky-ai
cd ~/mrblindside07-rocky-ai
chmod +x setup-linux.sh sync.sh
./setup-linux.sh
```

---

## 🔄 Cara Sinkronisasi Harian (Windows ↔ Fedora Linux)

### Saat update skill / rules di Windows (PC):
```powershell
.\sync.ps1 -Action push -Message "Update Rocky AI skills & rules"
```

### Saat sinkronisasi di Fedora Linux (Laptop):
```bash
cd ~/mrblindside07-rocky-ai && ./sync.sh pull
```
*Seketika itu juga Antigravity & Claude Code di Fedora Linux-mu langsung ter-update dengan persona Patrick Jane, rules, context, memory, dan 31 skill terbaru!* 🚀
