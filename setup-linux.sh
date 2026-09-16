#!/usr/bin/env bash
# ==============================================================================
#  mrblindside07-rocky-ai: Native Linux Setup (Arch Linux / Any Distro)
#  - Creates Live Symlinks for Skills & Directives (Instant Git Sync!)
#  - Installs Node.js, npm, & Playwright CLI
#  - Sets up MCP Servers & Notion Integration
# ==============================================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}======================================================"
echo -e "   ðŸš€ Setting up mrblindside07-rocky-ai on Linux"
echo -e "======================================================${NC}"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.gemini/config"
TARGET_CLAUDE_DIR="$HOME/.claude"

# 1. Dependency checks
echo -e "\n${YELLOW}[1/5] Checking dependencies...${NC}"
if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
    if command -v pacman &> /dev/null; then
        echo -e "${YELLOW}Installing nodejs & npm via pacman...${NC}"
        sudo pacman -S --needed --noconfirm nodejs npm
    elif command -v apt-get &> /dev/null; then
        echo -e "${YELLOW}Installing nodejs & npm via apt...${NC}"
        sudo apt-get update && sudo apt-get install -y nodejs npm
    fi
fi
echo -e "${GREEN}âœ“ Node $(node -v) & npm $(npm -v) ready.${NC}"

# 2. Directories
echo -e "\n${YELLOW}[2/5] Creating configuration directories...${NC}"
mkdir -p "$TARGET_CONFIG_DIR/mcp-servers/notion"
mkdir -p "$TARGET_CLAUDE_DIR"

# 3. Setup Symlinks (Live Link: Git Pull will auto-update skills instantly!)
echo -e "\n${YELLOW}[3/5] Creating live symlinks for skills & rules...${NC}"

# Backup existing folder if not symlink
if [ -d "$TARGET_CONFIG_DIR/skills" ] && [ ! -L "$TARGET_CONFIG_DIR/skills" ]; then
    mv "$TARGET_CONFIG_DIR/skills" "$TARGET_CONFIG_DIR/skills.bak.$(date +%s)"
fi
ln -sfn "$REPO_DIR/skills" "$TARGET_CONFIG_DIR/skills"
echo -e "${GREEN}âœ“ Live symlink: $TARGET_CONFIG_DIR/skills -> $REPO_DIR/skills${NC}"

# Also link to Claude Code skills if user uses Claude Code
if [ -d "$TARGET_CLAUDE_DIR/skills" ] && [ ! -L "$TARGET_CLAUDE_DIR/skills" ]; then
    mv "$TARGET_CLAUDE_DIR/skills" "$TARGET_CLAUDE_DIR/skills.bak.$(date +%s)"
fi
ln -sfn "$REPO_DIR/skills" "$TARGET_CLAUDE_DIR/skills"
echo -e "${GREEN}âœ“ Live symlink: $TARGET_CLAUDE_DIR/skills -> $REPO_DIR/skills${NC}"

# Copy or symlink GEMINI.md & CLAUDE.md
cp "$REPO_DIR/rules/GEMINI.md" "$TARGET_CONFIG_DIR/GEMINI.md"
cp "$REPO_DIR/rules/GEMINI.md" "$TARGET_CLAUDE_DIR/CLAUDE.md"
echo -e "${GREEN}âœ“ Installed global rules (GEMINI.md & CLAUDE.md)${NC}"

# 4. Config & MCP
echo -e "\n${YELLOW}[4/5] Setting up config.json & MCP servers...${NC}"
cp "$REPO_DIR/config/config.json" "$TARGET_CONFIG_DIR/config.json"

# Process Linux MCP template replacing $HOME
sed "s|\$HOME|$HOME|g" "$REPO_DIR/mcp/mcp_config.linux.json" > "$TARGET_CONFIG_DIR/mcp_config.json"
echo -e "${GREEN}âœ“ Configured mcp_config.json with Linux paths${NC}"

# Setup Notion runner
if [ -d "$REPO_DIR/mcp/notion" ]; then
    cp -r "$REPO_DIR/mcp/notion/"* "$TARGET_CONFIG_DIR/mcp-servers/notion/"
    echo "Installing Notion MCP packages..."
    (cd "$TARGET_CONFIG_DIR/mcp-servers/notion" && npm install --silent --no-audit)
fi

# 5. Playwright CLI
if ! command -v playwright-cli &> /dev/null; then
    echo -e "\n${YELLOW}[5/5] Installing Playwright CLI globally...${NC}"
    sudo npm install -g @playwright/cli@latest || npm install -g @playwright/cli@latest || true
fi

echo -e "\n${CYAN}======================================================"
echo -e "${GREEN}ðŸŽ‰ ALL SET! mrblindside07-rocky-ai is live on Linux!${NC}"
echo -e "${CYAN}======================================================${NC}"
echo -e "Skills linked: $(find "$REPO_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l) skills"
echo -e "To get updates later, just run: ${YELLOW}./sync.sh pull${NC}"
