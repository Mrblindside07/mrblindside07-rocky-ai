# ==============================================================================
#  mrblindside07-rocky-ai: Windows Setup Script
#  - Creates Symlink from repo to ~/.gemini/config/skills
#  - Syncs GEMINI.md, config.json, & mcp_config.json
# ==============================================================================

$repoDir = $PSScriptRoot
$configDir = "$env:USERPROFILE\.gemini\config"
$claudeDir = "$env:USERPROFILE\.claude"

Write-Host "Setting up mrblindside07-rocky-ai on Windows..." -ForegroundColor Cyan

# 1. Symlink skills to ~/.gemini/config/skills
$targetSkills = "$configDir\skills"
if (Test-Path $targetSkills) {
    # Check if directory or symlink
    $item = Get-Item $targetSkills
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "Skills is already a symlink." -ForegroundColor Green
    } else {
        Write-Host "Backing up existing skills to skills.bak..."
        Move-Item $targetSkills "$configDir\skills.bak" -Force
        New-Item -ItemType SymbolicLink -Path $targetSkills -Target "$repoDir\skills" -Force | Out-Null
        Write-Host "Created live symlink for skills!" -ForegroundColor Green
    }
} else {
    New-Item -ItemType SymbolicLink -Path $targetSkills -Target "$repoDir\skills" -Force | Out-Null
    Write-Host "Created live symlink for skills!" -ForegroundColor Green
}

# 2. Copy rules & config
Copy-Item "$repoDir\rules\GEMINI.md" "$configDir\GEMINI.md" -Force
Copy-Item "$repoDir\config\config.json" "$configDir\config.json" -Force
Copy-Item "$repoDir\mcp\mcp_config.windows.json" "$configDir\mcp_config.json" -Force

# 3. Copy notion mcp
$notionDir = "$configDir\mcp-servers\notion"
if (!(Test-Path $notionDir)) { New-Item -ItemType Directory -Path $notionDir -Force | Out-Null }
Copy-Item "$repoDir\mcp\notion\*" $notionDir -Recurse -Force

Write-Host "`nWindows Setup Complete! Linked to $repoDir\skills" -ForegroundColor Green
