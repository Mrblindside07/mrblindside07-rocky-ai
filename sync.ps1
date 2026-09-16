param(
    [string]$Action = "pull",
    [string]$Message = "Update skills & config"
)

if ($Action -eq "pull") {
    Write-Host "Pulling latest updates from GitHub..." -ForegroundColor Cyan
    git pull --rebase origin main
    Write-Host "Sync complete!" -ForegroundColor Green
} elseif ($Action -eq "push") {
    Write-Host "Pushing updates to GitHub: $Message" -ForegroundColor Cyan
    git add .
    git commit -m $Message
    git push origin main
    Write-Host "Push complete!" -ForegroundColor Green
} else {
    Write-Host "Usage: .\sync.ps1 -Action pull  OR  .\sync.ps1 -Action push -Message 'Update message'"
}
