# crewkit Quality Gates Reference

After receiving any worker's output, run the MUST checklist. Any MUST failure → reject with specific missing items. Never accept incomplete output.

## BA Gate
- [ ] One-sentence summary of who this solves what for
- [ ] User stories have Who/What/Why
- [ ] In scope / Out of scope boundaries explicit
- [ ] Acceptance criteria in Given-When-Then, each testable
- [ ] ≥3 edge/error scenarios covered
- [ ] Open questions tagged "Waiting for Supervisor"

## Architect Gate
- [ ] ≥2 candidate solutions with pros/cons matrix
- [ ] Recommendation has quantified rationale (not "feels better")
- [ ] API signatures include input/output types; DB tables include fields + types + indexes
- [ ] "UX Interface Boundary" section present
- [ ] Impact analysis: which existing code changes, which interfaces break, migration cost
- [ ] Feasibility explicit: Feasible / Feasible-with-prerequisites / Infeasible+alternative

## UX Gate
- [ ] Page flow covers normal + return paths
- [ ] Per-page state matrix: Normal / Loading / Empty / Error / Edge
- [ ] Interaction sequence covers ≥1 happy + ≥1 error path
- [ ] HTML prototype opens in browser and is clickable (M/L mandatory)
- [ ] Prototype uses real copy (no lorem ipsum)

## Coder Plan Gate
- [ ] Change scope precise to file paths and function/method names
- [ ] Steps numbered, each with expected output and dependency notes
- [ ] Unknowns tagged `[?]` with "who decides what"
- [ ] Self-test plan covers happy path + ≥2 error/edge cases
- [ ] L-level: Architect review completed (reviewer + date noted)

## Coder Code Gate (after coding)
- [ ] All changes within plan scope (no scope creep)
- [ ] Typecheck/lint pass
- [ ] All self-test cases pass
- [ ] No console.log / debug artifacts
- [ ] No hardcoded secrets

## Tester Gate
- [ ] Case matrix covers all arch doc interfaces + all ux doc states
- [ ] Each case: name + scenario + preconditions + steps + expected + actual
- [ ] System API / permission / external service cases tagged [Needs-Human]
- [ ] Bugs have severity (CRITICAL/HIGH/MEDIUM/LOW) + repro steps
- [ ] Regression checklist: "changed X, verified Y still works"

## PM Self-Check (before Supervisor acceptance)
- [ ] All worker MUST gates passed
- [ ] Architect ↔ UX alignment verified
- [ ] Workflow state table updated
- [ ] `memory/session/current-state.md` updated
- [ ] Blockers synced to Supervisor if any

---

## Architect ↔ UX Alignment

After both complete, cross-check:

| Check | Method | On Mismatch |
|-------|--------|-------------|
| UX-depended fields all in Architect interface boundary | Compare field-by-field | Missing → Architect adds |
| UX-assumed data shapes match Architect type defs | Compare type/field names | Mismatch → cheaper side adapts |
| Page flow covers all interface states | Check Loading/Error/Empty all have UI | Missing → UX adds |
| No orphan fields (in UX but not in Arch) | Search UX doc for undefined fields | Either add or remove |

---

## Rejection Handling

| Severity | Definition | Action |
|----------|-----------|--------|| **MINOR** | Missing SHOULD items or small MUST gaps | Mark gaps → same worker supplements (same session) |
| **MAJOR** | MUST items largely missing | Mark all gaps → same worker rewrites sections (one redo) |
| **FATAL** | Wrong direction entirely | Write "why wrong + correct direction" → re-dispatch fresh |

Architect reviewing Coder plan: max 1 rejection round. If 2nd round still fails → Architect writes the key sections themselves.

Worker timeout: >6 min no output → re-pull with "complete in 5 min" note.
3 consecutive failures → PM judges: self-complete or change strategy.
