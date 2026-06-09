# crewkit Collaboration Rules Reference

## Worker-to-Worker Communication

**Allowed** (through PM or by reading docs):
- Coder can ask Architect for tech detail clarification
- UX can ask Architect about interface field meanings

**Forbidden** (must go through PM):
- Coder cannot ask UX to change interaction design
- UX cannot ask Architect to change interface
- Any "change the design" request → PM arbitrates

---

## Parallel Dispatch

Architect and UX run in parallel (L-level Phase 2). PM handles the race:

```
Both dispatched → Architect finishes first → PM verifies interface boundary
→ forwards to UX → UX finalizes against real interface

UX finishes first → PM holds → waits for Architect → cross-check
→ if conflict, reject cheaper-to-fix side
```

Multi-coder parallel (M-level, ≥3 files, no shared dependencies):
1. List each coder's file set, confirm no overlap
2. Pre-extract shared constants/types/configs before dispatch
3. If shared types change → serial path first, others wait
4. PM integrates and verifies after parallel completion

---

## Supervisor Interface

You (PM) are the ONLY interface Supervisor talks to:

- Translate technical details into plain language
- BA doc ready → present to Supervisor for confirmation
- All done → present test summary for acceptance
- Supervisor rejects → get specific feedback ("what's missing", not "it's wrong")
- Middle phases → don't bother Supervisor unless blocked

Supervisor only does 3 things: state requirements, confirm BA doc, final accept.

---

## Anti-Deadlock

| Rule | Action |
|------|--------|| **Dedup before dispatch** | Check target output file exists before pulling worker |
| **6-min timeout** | 2 cron rounds with no output → re-pull, mark "complete in 5 min" |
| **Duplicate output** | Two workers same task → use later one, discard earlier |
| **Cron self-drive** | Cron prompt contains complete dispatch instructions |

## Cron Management

- Cron ONLY for async phases (Architect, UX, Tester in background)
- Coding is synchronous — no cron for Coder
- Phase transition: delete old cron → create new cron for current phase
- Cron prompt must be self-contained: what to check, which file, what to do
- Check interval: Architect/UX → 3 min, Tester → 2 min
