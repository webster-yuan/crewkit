#!/usr/bin/env bash
# crewkit install script (Unix / macOS / WSL)
# Copies crewkit skill to ~/.claude/skills/crewkit/
set -euo pipefail

SKILL_DIR="${HOME}/.claude/skills/crewkit"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== crewkit installer ==="

if [ -d "$SKILL_DIR" ]; then
  echo "crewkit already installed at $SKILL_DIR"
  echo "To reinstall, remove it first: rm -rf $SKILL_DIR"
  exit 1
fi

mkdir -p "$SKILL_DIR"
cp -r "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"
cp -r "$SCRIPT_DIR/templates" "$SKILL_DIR/"

echo "Installed to $SKILL_DIR"
echo ""
echo "Usage in any project:"
echo "  /crewkit          — activate multi-role workflow"
echo "  /crewkit:init     — scaffold docs/ + memory/ into current project"
echo ""
echo "Or just describe a feature — the skill auto-activates."
