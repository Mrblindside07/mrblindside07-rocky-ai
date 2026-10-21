#!/usr/bin/env bash
# Usage: ./sync.sh [pull|push "commit message"]

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="${1:-pull}"

if [ "$ACTION" = "pull" ]; then
    echo "Pulling latest skills and updates from GitHub..."
    git pull --rebase origin main
    
    # Sync global rules if config dir exists
    if [ -d "$HOME/.gemini/config" ]; then
        cp -f "$REPO_DIR/GEMINI.md" "$HOME/.gemini/config/GEMINI.md" 2>/dev/null || true
    fi
    if [ -d "$HOME/.claude" ]; then
        cp -f "$REPO_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md" 2>/dev/null || true
    fi
    
    echo "Sync complete! Skills and rules are up to date."
elif [ "$ACTION" = "push" ]; then
    MSG="${2:-Update skills & config}"
    echo "Pushing changes to GitHub: $MSG"
    git add .
    git commit -m "$MSG"
    git push origin main
    echo "Push complete!"
else
    echo "Usage: ./sync.sh pull  OR  ./sync.sh push 'message'"
fi
