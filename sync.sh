#!/usr/bin/env bash
# Usage: ./sync.sh [pull|push "commit message"]

ACTION="${1:-pull}"

if [ "$ACTION" = "pull" ]; then
    echo "Pulling latest skills and updates from GitHub..."
    git pull --rebase origin main
    echo "Sync complete!"
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
