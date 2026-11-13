#!/usr/bin/env bash
# ==============================================================================
#  mrblindside07-rocky-ai: Native Linux Setup (Fedora / Arch / Debian-Ubuntu)
#  - Creates Live Symlinks for Skills, Global Rules, Context, Memory & Decisions
#  - Installs Node.js, npm, git, ffmpeg, yt-dlp, uv & Playwright CLI
#  - Sets up MCP Servers & Notion Integration
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}======================================================"
echo -e "   Setting up Rocky AI (Patrick Jane IT Consultant)"
echo -e "======================================================${NC}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.gemini/config"
TARGET_CLAUDE_DIR="$HOME/.claude"

# 1. Dependency checks (Fedora dnf / Arch pacman / Debian apt)
echo -e "\n${YELLOW}[1/5] Checking dependencies...${NC}"
if command -v dnf &> /dev/null; then
    echo -e "${YELLOW}Detected Fedora/RHEL (dnf). Ensuring nodejs, npm, git, ffmpeg, yt-dlp...${NC}"
    sudo dnf install -y nodejs npm git
    # ffmpeg & yt-dlp (ffmpeg may require RPM Fusion; yt-dlp is in Fedora repos)
    sudo dnf install -y yt-dlp || true
    sudo dnf install -y ffmpeg || sudo dnf install -y ffmpeg-free || true
elif command -v pacman &> /dev/null; then
    echo -e "${YELLOW}Detected Arch Linux (pacman). Installing nodejs, npm, git, ffmpeg, yt-dlp...${NC}"
    sudo pacman -S --needed --noconfirm nodejs npm git ffmpeg yt-dlp
elif command -v apt-get &> /dev/null; then
    echo -e "${YELLOW}Detected Debian/Ubuntu (apt). Installing nodejs, npm, git, ffmpeg...${NC}"
    sudo apt-get update && sudo apt-get install -y nodejs npm git ffmpeg yt-dlp
fi
echo -e "${GREEN}OK: Node $(node -v) & npm $(npm -v) ready.${NC}"

# 2. Directories
echo -e "\n${YELLOW}[2/5] Creating configuration directories...${NC}"
mkdir -p "$TARGET_CONFIG_DIR/mcp-servers/notion"
mkdir -p "$TARGET_CLAUDE_DIR"

# 3. Setup Live Symlinks (Git Pull auto-updates skills, rules, context & memory instantly!)
echo -e "\n${YELLOW}[3/5] Creating live symlinks for skills, rules, context & memory...${NC}"

link_item() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "${dst}.bak.$(date +%s)"
    fi
    ln -sfn "$src" "$dst"
    echo -e "${GREEN}OK: Symlink $dst -> $src${NC}"
}

link_item "$REPO_DIR/skills" "$TARGET_CONFIG_DIR/skills"
link_item "$REPO_DIR/skills" "$TARGET_CLAUDE_DIR/skills"
link_item "$REPO_DIR/GEMINI.md" "$TARGET_CONFIG_DIR/GEMINI.md"
link_item "$REPO_DIR/CLAUDE.md" "$TARGET_CONFIG_DIR/CLAUDE.md"
link_item "$REPO_DIR/CLAUDE.md" "$TARGET_CLAUDE_DIR/CLAUDE.md"
[ -d "$REPO_DIR/context" ] && link_item "$REPO_DIR/context" "$TARGET_CONFIG_DIR/context"
[ -d "$REPO_DIR/memory" ] && link_item "$REPO_DIR/memory" "$TARGET_CONFIG_DIR/memory"
[ -d "$REPO_DIR/decisions" ] && link_item "$REPO_DIR/decisions" "$TARGET_CONFIG_DIR/decisions"
[ -f "$REPO_DIR/rules/DESIGN.md" ] && link_item "$REPO_DIR/rules/DESIGN.md" "$TARGET_CONFIG_DIR/DESIGN.md"

# 4. Config & MCP
echo -e "\n${YELLOW}[4/5] Setting up config.json & MCP servers...${NC}"
if [ -f "$REPO_DIR/config/config.json" ]; then
    cp "$REPO_DIR/config/config.json" "$TARGET_CONFIG_DIR/config.json"
fi

if [ -f "$REPO_DIR/mcp/mcp_config.linux.json" ]; then
    sed "s|\$HOME|$HOME|g" "$REPO_DIR/mcp/mcp_config.linux.json" > "$TARGET_CONFIG_DIR/mcp_config.json"
    echo -e "${GREEN}OK: Configured mcp_config.json with Linux paths${NC}"
fi

if [ -d "$REPO_DIR/mcp/notion" ] && [ -f "$REPO_DIR/mcp/notion/package.json" ]; then
    cp -r "$REPO_DIR/mcp/notion/"* "$TARGET_CONFIG_DIR/mcp-servers/notion/"
    echo "Installing Notion MCP packages..."
    (cd "$TARGET_CONFIG_DIR/mcp-servers/notion" && npm install --silent --no-audit)
fi

# 5. Playwright CLI & uv (for document-reader)
echo -e "\n${YELLOW}[5/5] Checking Playwright CLI & uv...${NC}"
if ! command -v playwright-cli &> /dev/null; then
    sudo npm install -g @playwright/cli@latest || npm install -g @playwright/cli@latest || true
fi
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}Note: Install 'uv' for /document-reader if needed: curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
fi

echo -e "\n${CYAN}======================================================"
echo -e "${GREEN}ALL SET! Rocky AI (Patrick Jane Persona) is live on Linux!${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "Skills linked: $(find "$REPO_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l) skills"
echo -e "To get future updates anytime, run: ${YELLOW}./sync.sh pull${NC}"
