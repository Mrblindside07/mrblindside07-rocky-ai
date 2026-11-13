#!/usr/bin/env bash
# Usage: ./sync.sh [pull|push "commit message"]

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.gemini/config"
TARGET_CLAUDE_DIR="$HOME/.claude"
ACTION="${1:-pull}"

ensure_links() {
    mkdir -p "$TARGET_CONFIG_DIR" "$TARGET_CLAUDE_DIR"
    ln -sfn "$REPO_DIR/skills" "$TARGET_CONFIG_DIR/skills"
    ln -sfn "$REPO_DIR/skills" "$TARGET_CLAUDE_DIR/skills"
    ln -sfn "$REPO_DIR/GEMINI.md" "$TARGET_CONFIG_DIR/GEMINI.md"
    ln -sfn "$REPO_DIR/CLAUDE.md" "$TARGET_CONFIG_DIR/CLAUDE.md"
    ln -sfn "$REPO_DIR/CLAUDE.md" "$TARGET_CLAUDE_DIR/CLAUDE.md"
    [ -d "$REPO_DIR/context" ] && ln -sfn "$REPO_DIR/context" "$TARGET_CONFIG_DIR/context"
    [ -d "$REPO_DIR/memory" ] && ln -sfn "$REPO_DIR/memory" "$TARGET_CONFIG_DIR/memory"
    [ -d "$REPO_DIR/decisions" ] && ln -sfn "$REPO_DIR/decisions" "$TARGET_CONFIG_DIR/decisions"
}

if [ "$ACTION" = "pull" ]; then
    echo "Pulling latest Rocky AI skills, persona rules, context, and memory from GitHub..."
    git -C "$REPO_DIR" pull --rebase origin main
    ensure_links
    echo "Sync complete! Antigravity & Claude Code are now up to date."
elif [ "$ACTION" = "push" ]; then
    MSG="${2:-Update Rocky AI skills & config}"
    echo "Pushing changes to GitHub: $MSG"
    git -C "$REPO_DIR" add .
    git -C "$REPO_DIR" commit -m "$MSG"
    git -C "$REPO_DIR" push origin main
    echo "Push complete!"
else
    echo "Usage: ./sync.sh pull  OR  ./sync.sh push 'message'"
fi
