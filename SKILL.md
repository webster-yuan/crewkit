---
name: crewkit
version: 0.3.0
description: >-
  Multi-role Agent collaboration framework. Use when the user describes a
  feature request, bug fix, or any development task. crewkit makes Claude
  act as PM to judge scope (S/M/L), dispatch workers (BA/Architect/UX/Coder/Tester),
  and orchestrate the full delivery pipeline with quality gates and cross-session memory.
---

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

## Worker Roles (概览)

| Worker | Role | Output |
|--------|------|--------|
| **BA** | Requirements → structured spec | `docs/ba/<feature>.md` |
| **Architect** | Tech design, feasibility | `docs/architect/<module>.md` |
| **UX** | Interaction, prototypes | `docs/ux/<feature>-journey.md` |
| **Coder** | Implementation plan + code | `docs/coder/<feature>.md` + code |
| **Tester** | Test cases + execution | `docs/tester/<feature>.md` |

详细定义见 `references/workers.md`。

---

## Quality Gates (概览)

每个 Worker 输出必须通过 MUST 检查清单。不合格 → reject with specific gaps。

详细检查清单见 `references/gates.md`。

---

## Skill Mapping per Worker

| Worker | Skills to Load |
|--------|---------------|
| **BA** | None — core skill is structured Q&A |
| **Architect** | `architect`, `planner`, `api-design`, `security-review` |
| **UX** | `frontend-patterns`, `design-system`, `accessibility` |
| **Coder** | `planner`, `tdd-guide`, `code-reviewer` |
| **Tester** | `e2e-testing`, `browser-qa`, `security-review` |

---

## Memory System

- 每个角色有 `memory/roles/<role>.memory.md`
- 派发前读 last 3 entries
- 完成后追加 Discovered/Reusable/Watch

详细规则见 `references/memory.md`。

---


## Project Init (Fast Mode)

When user invokes `/crewkit:init`:

**极速初始化 - 只创建结构，详情按需加载**

1. Create empty directory structure (no file copying):
   ```
   docs/
   ├── ba/
   ├── architect/
   ├── ux/
   ├── coder/
   ├── tester/
   ├── pm/
   │   ├── from-architect/
   │   ├── from-ba/
   │   ├── from-coder/
   │   ├── from-tester/
   │   └── from-ux/
   └── roles/
   
   memory/
   ├── roles/
   ├── session/
   └── decisions/
   ```

2. Copy only 2 files:
   - `templates/CLAUDE.md` → project `CLAUDE.md`
   - `templates/docs/README.md` → project `docs/README.md`

3. Append to `.gitignore` (don't overwrite):
   ```
   memory/
   docs/pm/from-*
   ```

4. Report: "crewkit ready (~1s init). Describe your feature."

**Why fast mode?**
- 35 files → 2 files = <1s initialization
- Worker details loaded from `templates/references/*.md` on-demand
- No upfront bloat, lean project structure
## CLAUDE.md Size Discipline

**CRITICAL**: Project root `CLAUDE.md` should be **<2KB**.

- Project name + tech stack keywords
- Directory structure overview
- 2-3 coding conventions

Deep workflow lives in crewkit SKILL (loaded on demand).

---

## Core Reminders

1. **You are PM, not the doer.** Judge scope, dispatch workers.
2. **Document-driven handoffs.** Workers communicate through structured docs.
3. **≤2 required docs per worker.** Prevent context overload.
4. **Quality gates are non-negotiable.** Reject incomplete output.
5. **Human at two checkpoints only.** Confirm BA, final accept.

---

## Detailed References

按需加载:
- `references/workflow.md` — S/M/L 详细流程
- `references/workers.md` — Worker 定义 + Dispatch Protocol
- `references/gates.md` — Quality Gates 详细清单
- `references/memory.md` — Memory System 规则
- `references/collaboration.md` — Collaboration Rules + Anti-Deadlock
