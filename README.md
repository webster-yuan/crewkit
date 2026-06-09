# crewkit — Multi-Role Agent Collaboration Framework

> A Claude Code skill that turns the "one agent does everything" anti-pattern into a **Supervisor + PM + 5 specialized Workers** pipeline.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-6C4DFF)](https://claude.ai/code)

*[中文文档](README.zh.md)*

---

## Why a SKILL instead of CLAUDE.md

### Load on Demand, Not Always in Context

If the full crewkit workflow (role definitions, Quality Gates, Dispatch Protocol, Anti-Deadlock) lived in your project's root `CLAUDE.md`, every session would auto-inject 6,000+ tokens of process documentation.

Debugging an API error? Those tokens are wasted. But the LLM still has to read them every turn.

With a SKILL:
- `CLAUDE.md` stays at 2KB: project intro + one line "use crewkit for features"
- "Implement a new feature" → LLM recognizes pattern → loads crewkit SKILL → full PM pipeline
- "Debug a 405 error" → crewkit stays unloaded → 6,000+ tokens saved

### Cross-Project Reusable

Install to `~/.claude/skills/` or `~/.hermes/skills/` once. All projects share it. No copy-paste of 25KB process docs per project.

### Composable

SKILLs aren't isolated. crewkit composes with `forensic-bisect` (for debugging), `skill-scout` (auto-matching skills before dispatching Workers), `desktop-app-secrets` (Electron security). CLAUDE.md can't dynamically combine per scenario.

---

## Why crewkit

### 1. Role Separation, Concrete Deliverables
Solo developers tend to "think as they code." crewkit splits development into PM/BA/Architect/UX/Coder/Tester — each producing independent documentation: requirements analysis, architecture decisions, interaction designs, test cases. It's no longer "code is the only artifact."

### 2. Document Growth Chain
`docs/` + `memory/` directories track project evolution:
- `docs/ba/` → requirements clarification
- `docs/architect/` → technical proposals + trade-off matrices
- `docs/tester/` → test case matrices + regression checklists
- `memory/roles/` → cross-session experience per role
New team members read documents to understand design, not guess from code.

### 3. Snapshot-Style Session Start
Every new session, PM checks `docs/pm/from-*/` (Worker completion notices) + `memory/session/current-state.md`. A 3-line status table replaces a 30-minute code scan. You immediately know "where we left off and who's up next."

### 4. Anti-Guess-Fix Mechanism
Coder requires Architect approval before coding. Tester requires UX documents before writing test cases. Quality Gates enforce "think first, code later" — blocking the #1 solo-dev trap: jumping to code on first impulse.

### 5. Context Budget Management
Each Worker sees only their slice — BA sees requirements, Architect sees interface boundaries, Coder sees implementation plans. No more "50KB of context in one session causing LLM attention drift." Models without prompt caching (like DeepSeek v4-pro) benefit significantly.

### 6. Enforced Structured Thinking
crewkit is fundamentally a thinking framework. BA forces you to ask "what does the user actually want?" Architect forces at least two candidate solutions. Tester forces failure scenarios and edge cases. Without this structure, most people skip straight to code.

### 7. Decision Audit Trail
Two weeks later, `docs/architect/` tells you *why* solution B was chosen over A — trade-off matrices, pros/cons, rationale. You don't just know "we picked B," you remember "what we were weighing at the time."

### 8. Delegation Safety Net
The 5-part Dispatch Protocol (identity + input + deliverable + discipline + delivery) is insurance against silent failure. Sub-agents can't ask questions or read memory — a single missing detail produces garbage. This template ensures every Worker gets complete task context.

---

## Installation

```bash
git clone https://github.com/webster-yuan/crewkit.git
cd crewkit
bash install.sh        # macOS / Linux / WSL
# or
.\install.ps1          # Windows PowerShell
```

Once installed to `~/.claude/skills/crewkit/`, it's available in any project.

## Quick Start

**1. Initialize crewkit in your project:**

In a Claude Code session:

```
/crewkit:init
```

This scaffolds `docs/`, `memory/`, and a `CLAUDE.md` template in your project root.

**2. Describe your feature:**

```
I want to add an audit log to the admin panel
```

Claude automatically acts as **PM** — judges the change level (S/M/L), dispatches the right workers (BA, Architect, UX, Coder, Tester), and orchestrates the full pipeline.

**3. You only step in twice:** confirm the requirements doc + final acceptance. Everything in between is PM-automated.

---

## Why Single-Agent Workflows Fail

Cramming requirements → architecture → code → testing into one agent triggers six systemic problems:

| Problem | Root Cause | Symptom |
|---------|-----------|---------|
| **Context overload** | One session holds the entire chain's context | LLM reasoning quality degrades the further you go; early details get lost |
| **Role confusion** | Same agent switches between architect, coder, tester mindsets | Loss of depth on each switch; design decisions and implementation contaminate each other |
| **No institutional memory** | Every new session starts from scratch | Previously researched constraints and pitfalls are gone — you step on the same rakes |
| **Long-chain decay** | Thousands of tokens of reasoning chain from requirements to tests | Decision quality at the tail (testing) is far below the head; testing becomes perfunctory |
| **Self-review blind spot** | Same agent reviews its own plan | Architecture gaps and edge-case omissions are nearly impossible to self-detect |
| **Human bottleneck** | Either the human watches everything (exhausting) or nothing (loss of control) | No structured intervention points between the two extremes |

### Root Cause

**LLM attention decay in long-context, multi-role-mixed scenarios.** As a single agent pushes forward on the requirements-to-delivery chain, context inflates at every step. By the time it reaches the back end (coding, testing), the original intent is buried under layers of prior reasoning — drift is inevitable.

---

## How crewkit Solves It

### Core Idea: Divide and Conquer

```
Traditional:                          crewkit:

Single Agent                          Supervisor (Human)
  │                                      │
  ├── Understand reqs (vague)            PM (orchestrator)
  ├── Design arch (off the cuff)         │
  ├── Write code (trial and error)       ├── BA        → requirements doc  [focus: clarify + bound]
  └── Test a bit (perfunctory)           ├── Architect → architecture doc  [focus: tech + feasibility]
                                         ├── UX        → interaction doc   [focus: flows + states]
                                         ├── Coder     → code              [focus: plan → implement]
                                         └── Tester    → test report       [focus: independent verify]
```

**Each Worker only processes context within its role.** BA doesn't need to know the tech stack. Coder doesn't need to re-derive requirements — they read BA's structured spec.

### Four Core Mechanisms

#### 1. Documents as Interfaces — structured artifacts replace raw context passing

Workers don't pass session histories. They pass **structured documents**. A 500-line architecture doc is a compressed distillation of thousands of lines of the Architect's reasoning. The next worker reads the doc, not replays the thought process.

```
Raw request (natural language, vague)
    → BA doc (structured spec, ~200 lines)
    → Architect doc (candidate solutions + interface definitions, ~300 lines)
    → UX doc (state matrix + flow diagrams, ~200 lines)
    → Coder plan (change scope + steps, ~150 lines)
    → Code
    → Tester report (test case matrix, ~150 lines)
```

Every step **refines and structures**, rather than blindly appending raw context.

#### 2. Role Isolation — each Worker has independent memory and context boundaries

| Isolation Dimension | Mechanism |
|--------------------|-----------|
| **Prompt isolation** | Each Worker injected with role-specific prompt defining scope and behavioral constraints |
| **Memory isolation** | Each Worker has its own `memory/roles/<role>.memory.md`, accumulating only its domain knowledge |
| **Context isolation** | Workers read only their required docs (≤2), shielded from other roles' noise |
| **Discipline isolation** | "Stay in your lane" — Architect doesn't design UI, UX doesn't decide data models, Coder doesn't make design decisions |

#### 3. Quality Gates — MUST checklists at every handoff

Every role handoff has a quality gate, executed by someone who is **not the producer**. Architect reviews Coder's plan. Tester independently verifies Coder's code. Cross-review naturally covers self-review blind spots.

#### 4. Cross-Session Memory — role knowledge compounds

After every task, each Worker appends to its memory file. Next time PM dispatches that role, the last 3 memory entries are injected into the prompt. Knowledge doesn't evaporate when the session ends.

---

## Flow Design: Three-Tier Triage

```
Supervisor states request
    │
    ▼
PM grades (no interface/data/flow changes → S-level)
    │
    ├── S-level (bug fix, copy tweak)
    │     PM → Coder directly → PM self-test (same session)
    │
    ├── M-level (new feature on existing module)
    │     PM pulls 1-2 workers → Coder → Tester (2-3 sessions)
    │
    └── L-level (new module, architecture change)
          Full 7-stage pipeline: BA → Architect∥UX → Coder + Tester
```

**Small changes don't mobilize the entire team.** Only major changes pull full firepower.

---

## Project Structure

```
crewkit/                              # ← this repo (skill source)
├── SKILL.md                          # Skill definition (Claude Code entry point)
├── README.md                         # This file
├── README.zh.md                      # Chinese documentation
├── install.sh / install.ps1          # Install scripts
├── templates/                        # Project scaffold (copied on /crewkit:init)
│   ├── CLAUDE.md                     #   PM protocol reference
│   ├── docs/                         #   Per-role output templates
│   │   ├── ba/                       #     BA: requirements + prototypes
│   │   ├── architect/                #     Architect: architecture + research + review
│   │   ├── ux/                       #     UX: interaction documents
│   │   ├── coder/                    #     Coder: implementation plans + debug
│   │   ├── tester/                   #     Tester: test reports + E2E
│   │   ├── pm/                       #     PM: dispatch protocols + quality gates + inbox
│   │   └── roles/                    #     Tech role definitions (frontend/backend/data/...)
│   └── memory/                       #   Cross-session role memory system
│       ├── roles/                    #     Per-worker knowledge accumulation
│       ├── session/current-state.md  #     Session state recovery
│       └── decisions/                #     Architecture Decision Records (ADR)
├── LICENSE                           # MIT
└── .gitignore
```

---

## Tech-Stack Agnostic

crewkit is a **methodology-level** skill. It doesn't bind to any language or framework:

- Frontend project? Inject `frontend-patterns` skill for UX + Coder
- Backend project? Inject `api-design` + `database-reviewer` for Architect
- Full-stack? Split by module — UI goes M-level (UX→Coder), API goes M-level (Architect→Coder)
- Non-software work (research reports, content production)? Keep BA + PM + Tester, swap the other roles for domain equivalents

What stays constant: **role separation, documents as interfaces, quality gates, cross-session memory**.

---

## How crewkit Differs from CrewAI / Multi-Agent SDKs

crewkit is often compared to **CrewAI** — the leading Python multi-agent framework. They solve different problems:

| | **CrewAI** | **crewkit** |
|---|-----------|------------|
| **What it is** | Python SDK — you write code to define agents | Claude Code skill — you talk to it |
| **Onboarding** | `pip install` + write Python/YAML | `/crewkit:init` then describe your feature |
| **Agent communication** | In-memory Python objects | Structured markdown documents (traceable, auditable) |
| **Context management** | No built-in limits | ≤2 required docs per worker (prevents attention decay) |
| **Quality control** | No built-in gates | MUST checklists at every handoff, reviewed by non-producer |
| **Human role** | Optional hook | **Structural — Supervisor is the pivot** of the entire workflow |
| **Cross-session memory** | Task-scoped | File-persisted per-role memory, compounds across sessions |
| **Task triage** | All tasks run same flow | S/M/L three-tier — small fixes don't mobilize the whole team |
| **Best for** | Building agent-based applications | Running a disciplined development process with AI agents |

**CrewAI is a library for building agent applications. crewkit is a protocol for running a development team of agents.** They're complementary — you could use crewkit to manage the development of a CrewAI-based app.

---

## Why "Supervisor" Not "Product Owner" or "Tech Lead"

People sometimes wonder: *"Am I the client now? I used to be the developer."*

You're neither. **Supervisor** is a distinct role:

- Not a **client** — this is your project, you're not outsourcing
- Not a **tech lead** — you don't manage people or write code
- You're a **decision-maker + quality inspector** — you define what to build (confirm BA doc), verify it's right (final acceptance), and trust the PM to handle everything in between

The depth didn't disappear — it shifted from *execution depth* (I know how to implement this) to *system depth* (I designed a protocol that keeps agents from drifting).

---

## Contributing

Issues and PRs welcome.

```bash
git clone https://github.com/webster-yuan/crewkit.git
cd crewkit
# SKILL.md is the main file, templates/ is the scaffold
```


## Versions

| Version | Init Mode | Init Time | Notes |
|---------|-----------|-----------|-------|
| **v0.3.0** | Fast | <1s | Only directory structure + 2 core files |
| **v0.2.0** | Standard | ~6s | Full templates + references (35 files) |
| **v0.1.0** | Full | ~15s | Complete copy including memory templates |

## License

MIT — see [LICENSE](LICENSE)
