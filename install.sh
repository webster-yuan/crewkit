#!/usr/bin/env bash
# crewkit install script (Unix / macOS / WSL)
# Copies crewkit skill to ~/.claude/skills/crewkit/
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/crewkit"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_VERSION="$(cat "$SCRIPT_DIR/VERSION")"

usage() {
  echo "Usage: ./install.sh [--force] [--upgrade] [--check] [--verify]"
  echo ""
  echo "  (no flag)   Fresh install"
  echo "  --force     Remove existing installation and reinstall"
  echo "  --upgrade   Upgrade installed version to latest (keeps project data)"
  echo "  --check     Compare installed version vs available version"
  echo "  --verify    Verify installed file integrity"
  exit 0
}

do_install() {
  mkdir -p "$SKILL_DIR"
  cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
  cp "$SCRIPT_DIR/SKILL.zh.md" "$SKILL_DIR/"
  cp -r "$SCRIPT_DIR/templates" "$SKILL_DIR/"
  cp -r "$SCRIPT_DIR/references" "$SKILL_DIR/"
  cp "$SCRIPT_DIR/VERSION" "$SKILL_DIR/"
  echo "Installed to $SKILL_DIR (v$REPO_VERSION)"
  echo ""
  echo "Usage in any project:"
  echo "  /crewkit          — activate multi-role workflow"
  echo "  /crewkit:init     — scaffold docs/ + memory/ into current project"
  echo ""
  echo "Or just describe a feature — the skill auto-activates."
}

cmd_check() {
  if [ ! -f "$SKILL_DIR/VERSION" ]; then
    echo "crewkit is not installed (no VERSION file found)."
    echo "Run ./install.sh to install."
    exit 1
  fi
  INSTALLED_VERSION="$(cat "$SKILL_DIR/VERSION")"
  echo "Installed: v$INSTALLED_VERSION"
  echo "Available: v$REPO_VERSION"
  if [ "$INSTALLED_VERSION" = "$REPO_VERSION" ]; then
    echo "✅ Up to date."
  else
    echo "⚠️  Update available. Run ./install.sh --upgrade to upgrade."
  fi
}

cmd_upgrade() {
  if [ ! -d "$SKILL_DIR" ]; then
    echo "crewkit is not installed. Run ./install.sh to install."
    exit 1
  fi
  INSTALLED_VERSION="N/A"
  if [ -f "$SKILL_DIR/VERSION" ]; then
    INSTALLED_VERSION="$(cat "$SKILL_DIR/VERSION")"
  fi
  echo "Upgrading crewkit v$INSTALLED_VERSION → v$REPO_VERSION"
  # Backup only the version file for rollback reference
  cp "$SKILL_DIR/VERSION" "$SKILL_DIR/VERSION.bak" 2>/dev/null || true
  # Overwrite skill files (preserves any user-created files in templates/)
  cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
  cp "$SCRIPT_DIR/SKILL.zh.md" "$SKILL_DIR/"
  cp -r "$SCRIPT_DIR/templates/"* "$SKILL_DIR/templates/"
  cp -r "$SCRIPT_DIR/references/"* "$SKILL_DIR/references/"
  cp "$SCRIPT_DIR/VERSION" "$SKILL_DIR/"
  rm -f "$SKILL_DIR/VERSION.bak"
  echo "✅ Upgraded to v$REPO_VERSION"
}

cmd_verify() {
  if [ ! -d "$SKILL_DIR" ]; then
    echo "❌ crewkit is not installed at $SKILL_DIR"
    exit 1
  fi
  ERRORS=0
  echo "Verifying crewkit installation..."
  echo ""

  # Check SKILL.md exists and has valid frontmatter
  if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    echo "❌ SKILL.md missing"
    ERRORS=$((ERRORS + 1))
  else
    if head -1 "$SKILL_DIR/SKILL.md" | grep -q '^---$'; then
      echo "✅ SKILL.md exists with frontmatter"
    else
      echo "⚠️  SKILL.md exists but frontmatter not detected"
    fi
  fi

  # Check templates directory
  if [ ! -d "$SKILL_DIR/templates" ]; then
    echo "❌ templates/ missing"
    ERRORS=$((ERRORS + 1))
  else
    TEMPLATE_COUNT=$(find "$SKILL_DIR/templates" -name "*.md" | wc -l)
    echo "✅ templates/ ($TEMPLATE_COUNT markdown files)"
  fi

  # Check references directory
  if [ ! -d "$SKILL_DIR/references" ]; then
    echo "❌ references/ missing"
    ERRORS=$((ERRORS + 1))
  else
    REF_COUNT=$(find "$SKILL_DIR/references" -name "*.md" | wc -l)
    echo "✅ references/ ($REF_COUNT files: $(ls "$SKILL_DIR/references/" | tr '\n' ' '))"
  fi

  # Check VERSION
  if [ -f "$SKILL_DIR/VERSION" ]; then
    echo "✅ VERSION: $(cat "$SKILL_DIR/VERSION")"
  else
    echo "⚠️  VERSION file missing"
  fi

  echo ""
  if [ "$ERRORS" -eq 0 ]; then
    echo "✅ All checks passed."
  else
    echo "❌ $ERRORS check(s) failed. Re-run ./install.sh --force to repair."
    exit 1
  fi
}

# Main
case "${1:-}" in
  --force)
    echo "=== crewkit installer (force) ==="
    rm -rf "$SKILL_DIR"
    do_install
    ;;
  --upgrade)
    echo "=== crewkit upgrader ==="
    cmd_upgrade
    ;;
  --check)
    echo "=== crewkit version check ==="
    cmd_check
    ;;
  --verify)
    echo "=== crewkit integrity check ==="
    cmd_verify
    ;;
  --help|-h)
    usage
    ;;
  "")
    echo "=== crewkit installer ==="
    if [ -d "$SKILL_DIR" ]; then
      echo "crewkit already installed at $SKILL_DIR"
      echo "Use --force to reinstall, --upgrade to upgrade, --check to compare versions."
      exit 1
    fi
    do_install
    ;;
  *)
    echo "Unknown option: $1"
    usage
    ;;
esac
