# crewkit install script (Windows PowerShell)
# Copies crewkit skill to ~/.claude/skills/crewkit/
param(
    [switch]$Force,
    [switch]$Upgrade,
    [switch]$Check,
    [switch]$Verify,
    [switch]$Help
)

$SkillDir = "$env:USERPROFILE\.claude\skills\crewkit"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoVersion = (Get-Content "$ScriptDir\VERSION").Trim()

function Show-Usage {
    Write-Host "Usage: .\install.ps1 [-Force] [-Upgrade] [-Check] [-Verify] [-Help]"
    Write-Host ""
    Write-Host "  (no flag)   Fresh install"
    Write-Host "  -Force      Remove existing installation and reinstall"
    Write-Host "  -Upgrade    Upgrade installed version to latest (keeps project data)"
    Write-Host "  -Check      Compare installed version vs available version"
    Write-Host "  -Verify     Verify installed file integrity"
    Write-Host "  -Help       Show this help"
}

function Do-Install {
    New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null
    Copy-Item "$ScriptDir\SKILL.md" -Destination "$SkillDir\"
    Copy-Item "$ScriptDir\SKILL.zh.md" -Destination "$SkillDir\"
    Copy-Item "$ScriptDir\templates" -Destination "$SkillDir\" -Recurse
    Copy-Item "$ScriptDir\references" -Destination "$SkillDir\" -Recurse
    Copy-Item "$ScriptDir\VERSION" -Destination "$SkillDir\"
    Write-Host "Installed to $SkillDir (v$RepoVersion)"
    Write-Host ""
    Write-Host "Usage in any project:"
    Write-Host "  /crewkit          — activate multi-role workflow"
    Write-Host "  /crewkit:init     — scaffold docs/ + memory/ into current project"
    Write-Host ""
    Write-Host "Or just describe a feature — the skill auto-activates."
}

function Do-Check {
    if (-not (Test-Path "$SkillDir\VERSION")) {
        Write-Host "crewkit is not installed (no VERSION file found)."
        Write-Host "Run .\install.ps1 to install."
        exit 1
    }
    $InstalledVersion = (Get-Content "$SkillDir\VERSION").Trim()
    Write-Host "Installed: v$InstalledVersion"
    Write-Host "Available: v$RepoVersion"
    if ($InstalledVersion -eq $RepoVersion) {
        Write-Host "✅ Up to date."
    } else {
        Write-Host "⚠️  Update available. Run .\install.ps1 -Upgrade to upgrade."
    }
}

function Do-Upgrade {
    if (-not (Test-Path $SkillDir)) {
        Write-Host "crewkit is not installed. Run .\install.ps1 to install."
        exit 1
    }
    $InstalledVersion = "N/A"
    if (Test-Path "$SkillDir\VERSION") {
        $InstalledVersion = (Get-Content "$SkillDir\VERSION").Trim()
        Copy-Item "$SkillDir\VERSION" "$SkillDir\VERSION.bak" -ErrorAction SilentlyContinue
    }
    Write-Host "Upgrading crewkit v$InstalledVersion → v$RepoVersion"
    # Overwrite skill files
    Copy-Item "$ScriptDir\SKILL.md" -Destination "$SkillDir\" -Force
    Copy-Item "$ScriptDir\SKILL.zh.md" -Destination "$SkillDir\" -Force
    Copy-Item "$ScriptDir\templates\*" -Destination "$SkillDir\templates\" -Recurse -Force
    Copy-Item "$ScriptDir\references\*" -Destination "$SkillDir\references\" -Recurse -Force
    Copy-Item "$ScriptDir\VERSION" -Destination "$SkillDir\" -Force
    Remove-Item "$SkillDir\VERSION.bak" -ErrorAction SilentlyContinue
    Write-Host "✅ Upgraded to v$RepoVersion"
}

function Do-Verify {
    if (-not (Test-Path $SkillDir)) {
        Write-Host "❌ crewkit is not installed at $SkillDir"
        exit 1
    }
    $Errors = 0
    Write-Host "Verifying crewkit installation..."
    Write-Host ""

    # Check SKILL.md exists and has valid frontmatter
    if (-not (Test-Path "$SkillDir\SKILL.md")) {
        Write-Host "❌ SKILL.md missing"
        $Errors++
    } else {
        $firstLine = Get-Content "$SkillDir\SKILL.md" -First 1
        if ($firstLine -eq "---") {
            Write-Host "✅ SKILL.md exists with frontmatter"
        } else {
            Write-Host "⚠️  SKILL.md exists but frontmatter not detected"
        }
    }

    # Check templates directory
    if (-not (Test-Path "$SkillDir\templates")) {
        Write-Host "❌ templates/ missing"
        $Errors++
    } else {
        $templateCount = (Get-ChildItem "$SkillDir\templates" -Recurse -Filter "*.md").Count
        Write-Host "✅ templates/ ($templateCount markdown files)"
    }

    # Check references directory
    if (-not (Test-Path "$SkillDir\references")) {
        Write-Host "❌ references/ missing"
        $Errors++
    } else {
        $refFiles = (Get-ChildItem "$SkillDir\references" -Filter "*.md" | ForEach-Object { $_.Name }) -join " "
        $refCount = (Get-ChildItem "$SkillDir\references" -Filter "*.md").Count
        Write-Host "✅ references/ ($refCount files: $refFiles)"
    }

    # Check VERSION
    if (Test-Path "$SkillDir\VERSION") {
        Write-Host "✅ VERSION: $(Get-Content $SkillDir\VERSION)"
    } else {
        Write-Host "⚠️  VERSION file missing"
    }

    Write-Host ""
    if ($Errors -eq 0) {
        Write-Host "✅ All checks passed."
    } else {
        Write-Host "❌ $Errors check(s) failed. Re-run .\install.ps1 -Force to repair."
        exit 1
    }
}

# Main
Write-Host "=== crewkit ==="

if ($Help) {
    Show-Usage
    exit 0
}

if ($Check) {
    Do-Check
    exit 0
}

if ($Verify) {
    Do-Verify
    exit 0
}

if ($Upgrade) {
    Do-Upgrade
    exit 0
}

if ($Force) {
    if (Test-Path $SkillDir) {
        Remove-Item -Recurse -Force $SkillDir
        Write-Host "Removed existing installation."
    }
    Do-Install
    exit 0
}

# Default: fresh install
if (Test-Path $SkillDir) {
    Write-Host "crewkit already installed at $SkillDir"
    Write-Host "Use -Force to reinstall, -Upgrade to upgrade, -Check to compare versions."
    exit 1
}
Do-Install
