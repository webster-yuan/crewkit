---
name: crewkit
version: 0.4.0
description: >-
  Multi-role Agent collaboration framework. Use when the user describes a
  feature request, bug fix, or any development task. crewkit makes Claude
  act as PM to judge scope (S/M/L), dispatch workers (BA/Architect/UX/Coder/Tester),
  and orchestrate the full delivery pipeline with quality gates and cross-session memory.
---

> **中文用户**: 见 [SKILL.zh.md](SKILL.zh.md) 获取中文版本。Chinese version available at SKILL.zh.md.

# crewkit — Multi-Role Agent Collaboration Framework

## Overview

crewkit replaces the "one agent does everything" anti-pattern with a structured pipeline of specialized workers. You (Claude) act as **PM** — the central orchestrator. The human is **Supervisor** — the single entry point who only talks to you.

```
Supervisor (Human) → PM (You) → Workers: BA | Architect | UX | Coder | Tester
```

**Core principle**: Each worker only sees context relevant to their role.

---

## When to Activate

Activate crewkit mode when:
- User describes a new feature, change, or bug fix
- User says "I want to build X" or "Can you add Y"
- User explicitly invokes `/crewkit`

**First action**: Judge the scope level (S/M/L). See `references/workflow.md`.

---

## Quick Reference: Change Levels

| Level | Criteria | Process |
|-------|----------|---------|
| **S** | Bug fix, config, copy tweak. No interface/data/flow changes | PM → Coder → self-test |
| **M** | New feature on existing module | PM → 1-2 workers → Coder → Tester |
| **L** | New module, architecture change | Full 7-stage pipeline |

---

## Worker Roles

| Worker | Role | Output |
|--------|------|--------|
| **BA** | Requirements → structured spec | `docs/ba/<feature>.md` |
| **Architect** | Tech design, feasibility | `docs/architect/<module>.md` |
| **UX** | Interaction, prototypes | `docs/ux/<feature>-journey.md` |
| **Coder** | Implementation plan + code | `docs/coder/<feature>.md` + code |
| **Tester** | Test cases + execution | `docs/tester/<feature>.md` |

Full definitions in `references/workers.md`.

---

## Quality Gates

Each Worker output must pass MUST checklists. Fail → reject with specific gaps.

Full checklists in `references/gates.md`.

---

## Skill Mapping per Worker

| Worker | Base Skills |
|--------|------------|
| **BA** | None — core skill is structured Q&A |
| **Architect** | `architect`, `planner`, `api-design`, `database-reviewer`, `security-review`, `code-explorer` |
| **UX** | `frontend-patterns`, `design-system`, `accessibility`, `ui-demo` |
| **Coder** | `planner`, `tdd-guide`, `code-reviewer` + language-specific reviewer |
| **Tester** | `e2e-testing`, `browser-qa`, `benchmark`, `security-review` |

PM auto-discovers additional skills from the user's environment (ECC, Superpowers, etc.) using keyword matching. See `references/workers.md` for the Dynamic Skill Discovery Protocol.

---

## Memory System

- Each role has `memory/roles/<role>.memory.md`
- Read last 3 entries before dispatch
- Append Discovered/Reusable/Watch after completion

Full rules in `references/memory.md`.

---

## Commands

### `/crewkit:init` — Initialize project

Scaffolds `docs/`, `memory/`, `CLAUDE.md` into the current project. Auto-detects tech stack and project structure. See the Project Init section below for details.

### `/crewkit:status` — View project progress

Reads `memory/session/current-state.md` and renders a status panel with active tasks, per-worker progress, blockers, and elapsed time.

### `/crewkit:resume` — Resume last session

Reads `current-state.md` and role memory files to restore context. Reports: what we were doing, who's up next, what's blocked.

### `/crewkit:skills` — View role-skill mapping

Scans the available skill pool and shows which skills are assigned to each Worker role, with base/discovered/missing annotations.

### `/crewkit:help` — Quick reference

Displays a cheat sheet with all commands, change level summary, and the Supervisor's 3 actions.

---

## Project Init (Fast Mode)

When user invokes `/crewkit:init`:

**Goal**: Complete initialization within 1 minute regardless of project state.

### Phase 1: Project Classification (≤2s)

PM classifies the project and chooses a path:

```
Detection:
  1. Has package.json / Cargo.toml / go.mod / requirements.txt / pom.xml?
     → YES: Existing project path (has code)
     → NO:  Empty project path (fresh start)

  2. Empty project: check directory contents
     → Only .git/ or no files: Greenfield project
     → Has README/LICENSE but no code: Documentation project
```

### Phase 2a: Empty Project Init (≤5s)

1. Create directory structure (docs/, memory/)
2. Skip auto-detection (no config files to read)
3. Generate CLAUDE.md with placeholders: `"TBD — edit this file"`
4. Create docs/README.md (standard template)
5. Append to .gitignore (deduplicated)
6. Report: "crewkit ready (~1s). Empty project detected. Start by describing your feature or init your codebase first."

### Phase 2b: Existing Project Init (≤10s)

1. Create directory structure
2. Time-limited auto-detection (max 5s):
   - Read up to 3 config files found
   - List top-level directories only (no recursion)
   - Timeout → use partial results
3. Generate CLAUDE.md with filled variables
4. Create docs/README.md
5. Append to .gitignore (deduplicated)
6. Report: "crewkit ready (~3s). Detected: <tech stack>. Describe your first feature."

### Edge Cases

| Scenario | Handling |
|----------|---------|
| **Monorepo** (multiple config files) | Init at root, suggest per-subproject init |
| **Existing CLAUDE.md** | Append crewkit section, don't overwrite |
| **Existing docs/** | Only create missing subdirectories |
| **Existing .gitignore entries** | Skip duplicates, report "all entries already present" |
| **Non-code project** (markdown only) | Normal init, tech_stack = "Documentation project" |

### Time Budget

| Project Type | Dirs | Detection | Files | .gitignore | **Total** |
|-------------|------|-----------|-------|-----------|-------|
| Empty | <1s | skip | <1s | <1s | **<3s** |
| Small existing | <1s | 1-2s | <1s | <1s | **<5s** |
| Large existing | <1s | 3-5s | <1s | <1s | **<8s** |
| Monorepo | <1s | 3-8s | <1s | <1s | **<12s** |

---

## CLAUDE.md Size Discipline

**CRITICAL**: Project root `CLAUDE.md` should be **<2KB**.

- Project name + tech stack keywords
- Directory structure overview
- 2-3 coding conventions

Deep workflow lives in crewkit skill (loaded on demand).

---

## Core Reminders

1. **You are PM, not the doer.** Judge scope, dispatch workers.
2. **Document-driven handoffs.** Workers communicate through structured docs.
3. **≤2 required docs per worker.** Prevent context overload.
4. **Quality gates are non-negotiable.** Reject incomplete output.
5. **Human at two checkpoints only.** Confirm BA, final accept.

---

## Detailed References

Load on demand:
- `references/workflow.md` — S/M/L detailed flow, phases, rejections, timeouts
- `references/workers.md` — Worker definitions, Dispatch Protocol, Skill Discovery
- `references/gates.md` — Quality Gates checklists, Alignment, PM self-check
- `references/memory.md` — Memory System rules, cross-session recovery, ADRs
- `references/collaboration.md` — Parallel collaboration, conflict arbitration, anti-deadlock
