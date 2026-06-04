# CLAUDE.md

This project uses **crewkit** for multi-role Agent collaboration.

## Quick Reference

| Level | When | Flow |
|-------|------|------|
| **S** | Bug fix, config, typo, style | PM → Coder → self-test |
| **M** | Feature on existing module | PM → 1-2 specialists → Coder → Tester |
| **L** | New module, cross-module change | Full 7-role pipeline |

## Tech Stack
${project_tech_stack}

## Directory Structure
${project_structure}

## Coding Conventions
- Prefer const over let, functional style, early returns
- Type everything, no `any`
- Chinese comments OK, English identifiers

---

For the full crewkit workflow (Worker dispatch, Quality Gates, Memory system, Anti-deadlock),
refer to the crewkit skill documentation. This CLAUDE.md is intentionally kept <2KB to avoid
context bloat — the full methodology is loaded on demand by the crewkit skill.
