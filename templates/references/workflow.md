# crewkit Workflow Reference

## Change Grading (ALWAYS FIRST)

Before doing anything else, classify the request:

| Level | Criteria | Process | Timeframe |
|-------|----------|---------|-----------|| **S** | Bug fix, copy/style tweak, config change. Does NOT change interfaces, data models, or business logic flow | PM → Coder directly → PM self-test | Same session |
| **M** | New feature on existing module, new endpoint. Touches 1-2 domains | PM pulls 1-2 workers → Coder → Tester | 2-3 sessions |
| **L** | New module, cross-module refactor, architecture change | Full 7-stage pipeline | Paced |

**S-level gate**: All three must be true — no interface change AND no data model change AND no business flow change. If any one fails, it's at least M.

### How to Judge

Ask yourself these questions about the request:
1. Does this touch the database schema or API contracts? → If yes, at least M
2. Does this change how users interact with the system? → If yes, at least M
3. Is this a new capability that doesn't exist yet? → If yes, at least M
4. Is this purely fixing broken behavior to match existing spec? → S

When unsure between S and M, default to M.

---

## S-Level: Fast Track

```
Supervisor says "fix/change X"
  → PM confirms S-level (no interface/data/flow changes)
  → PM pulls Coder directly (same session)
  → Coder implements
  → PM self-tests
  → Done
```

Do NOT spin up BA, Architect, UX, or Tester for S-level tasks.

---

## M-Level: Selective Pipeline

Pull only the workers needed, based on what the change touches:

| Change touches | Pull | Skip |
|---------------|------|------|| UI/interaction/styling only | UX → Coder → Tester | Architect |
| Backend/data/API only | Architect → Coder → Tester | UX |
| Both UI and backend | Architect ∥ UX → Coder → Tester | — |

Tester is ALWAYS the final gate for M-level. Never skip Tester on M.

---

## L-Level: Full Pipeline

```
Phase 0: PM grades + scopes                    (~1 min)
Phase 1: BA clarifies → Supervisor confirms    (~15 min)
Phase 2: Architect ∥ UX design in parallel     (~15 min)
Phase 3: Coder plan → Architect review → code  (~30 min)
Phase 4: PM self-test → Tester independent test (~15 min)
Phase 5: Supervisor acceptance                  (~5 min)
```

### L-Level Detailed Flow

```
Supervisor ──→ PM judges L-level, pulls BA
                │
                ↓ BA produces docs/ba/<feature>.md
           PM reviews → Supervisor confirms ──→ reject → BA revises
                │
                ↓ approved
           PM pulls Architect ∥ UX in parallel
                │                    │
                ↓ arch doc           ↓ ux doc
           PM runs alignment check (see Quality Gates)
                │
                ↓ aligned
           PM pulls Coder (plan first)
           Coder plan → Architect review (max 1 rejection round)
                │
                ↓ plan approved
           PM dispatches in parallel:
             Coder codes ┃ Tester writes test cases
                │              │
                ↓ code         ↓ test cases ready
           PM self-tests → Tester executes
                │
                ↓ test report
           PM summarizes → Supervisor accepts
```
