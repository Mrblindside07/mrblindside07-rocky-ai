# ==============================================================================
#  mrblindside07-rocky-ai: Windows Setup Script
#  - Creates Directory Junction from repo to ~/.gemini/config/skills (No Admin required!)
#  - Syncs GEMINI.md, config.json, & mcp_config.json
# ==============================================================================

$repoDir = $PSScriptRoot
$configDir = "$env:USERPROFILE\.gemini\config"

Write-Host "Setting up mrblindside07-rocky-ai on Windows..." -ForegroundColor Cyan

# 1. Junction skills to ~/.gemini/config/skills
$targetSkills = "$configDir\skills"
if (Test-Path $targetSkills) {
    Remove-Item $targetSkills -Recurse -Force
}

New-Item -ItemType Junction -Path $targetSkills -Target "$repoDir\skills" -Force | Out-Null
Write-Host "Created live Directory Junction: $targetSkills -> $repoDir\skills" -ForegroundColor Green

# 2. Copy rules & config
Copy-Item "$repoDir\rules\GEMINI.md" "$configDir\GEMINI.md" -Force
Copy-Item "$repoDir\config\config.json" "$configDir\config.json" -Force
Copy-Item "$repoDir\mcp\mcp_config.windows.json" "$configDir\mcp_config.json" -Force

# 3. Copy notion mcp
$notionDir = "$configDir\mcp-servers\notion"
if (!(Test-Path $notionDir)) { New-Item -ItemType Directory -Path $notionDir -Force | Out-Null }
Copy-Item "$repoDir\mcp\notion\*" $notionDir -Recurse -Force

Write-Host "`nWindows Setup Complete! Linked natively to $repoDir\skills" -ForegroundColor Green
