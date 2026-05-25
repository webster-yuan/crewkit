# crewkit install script (Windows PowerShell)
# Copies crewkit skill to ~/.claude/skills/crewkit/
param(
    [switch]$Force
)

$SkillDir = "$env:USERPROFILE\.claude\skills\crewkit"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== crewkit installer ==="

if (Test-Path $SkillDir) {
    if ($Force) {
        Remove-Item -Recurse -Force $SkillDir
        Write-Host "Removed existing installation."
    } else {
        Write-Host "crewkit already installed at $SkillDir"
        Write-Host "To reinstall, use: .\install.ps1 -Force"
        exit 1
    }
}

New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
Copy-Item "$ScriptDir\SKILL.md" -Destination "$SkillDir\"
Copy-Item "$ScriptDir\templates" -Destination "$SkillDir\" -Recurse

Write-Host "Installed to $SkillDir"
Write-Host ""
Write-Host "Usage in any project:"
Write-Host "  /crewkit          — activate multi-role workflow"
Write-Host "  /crewkit:init     — scaffold docs/ + memory/ into current project"
Write-Host ""
Write-Host "Or just describe a feature — the skill auto-activates."
