# CLAUDE.md

This file provides guidance to Claude Code when working in the crewkit repository itself.

## Project Overview

crewkit is a Claude Code skill that implements a multi-role Agent collaboration
framework. This repo is the skill source — install it to `~/.claude/skills/crewkit/`
or share via GitHub.

## Repo Structure

```
crewkit/
├── SKILL.md              # Skill definition (entry point for Claude Code)
├── README.md             # GitHub-facing README
├── LICENSE               # MIT
├── install.sh            # Unix install script
├── install.ps1           # Windows install script
├── templates/            # Files copied into user projects on init
│   ├── CLAUDE.md         # Project template (PM protocol reference)
│   ├── docs/             # Doc templates per role
│   └── memory/           # Memory file templates
└── .gitignore
```

## Working on crewkit

When editing crewkit itself:
- **SKILL.md** is the main file — it defines what Claude does when the skill activates
- **templates/CLAUDE.md** is the project-level reference doc (installed into projects that want a static reference)
- **templates/docs/** and **templates/memory/** are scaffold files copied by `/crewkit:init`

## Conventions

- SKILL.md should be self-contained enough to drive PM behavior without requiring reads of template files
- Template files should be kept in sync with SKILL.md when protocols change
- README.md targets GitHub visitors — explain why, not just what
