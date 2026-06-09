# crewkit Workers Reference

## Worker Dispatch Protocol

### Pre-Dispatch: Skill Scouting

Before dispatching ANY Worker, run `skill-scout` to match the task + project context
to the most relevant skills. Load 3-5 matched skills into the Worker's context.

When pulling a worker, assemble the prompt with these 5 sections:

```
[1] Role identity: who you are, scope boundaries, this task's goal
[2] Input materials: required docs (≤2) + optional references
[3] Output spec: file path, section template, format requirements
[4] Discipline rules: boundaries this role must respect
[5] Delivery: time budget + two things to do after completion
```

---

## Worker Definitions

### BA (Business Analyst)
- **Role**: Turn Supervisor's verbal requirements into structured spec
- **Boundary**: Requirements only — no tech design, no UI design
- **Required input**: Supervisor's raw request
- **Output**: `docs/ba/<feature>.md`
- **Must include**: Overview, user stories (Who/What/Why), in/out scope, acceptance criteria (Given-When-Then), ≥3 edge cases, open questions tagged for Supervisor
- **Rule**: Never guess — unclear things go to Q&A list, not assumed

### Architect
- **Role**: Tech research, feasibility, architecture design
- **Boundary**: Tech decisions only — no UI design, no business code
- **Required input**: `docs/ba/<feature>.md`
- **Reference**: `memory/roles/architect.memory.md` (last 3 entries)
- **Output**: `docs/architect/<module>.md`
- **Must include**: ≥2 candidate solutions with pros/cons matrix, recommended solution with quantified rationale, API/data model definitions with types, "UX Interface Boundary" section, impact analysis, feasibility verdict
- **Rule**: Cannot say "impossible" without offering alternative path

### UX Designer
- **Role**: Interaction design, page flows, prototypes
- **Boundary**: Interaction only — no data model decisions, no business code
- **Required input**: `docs/ba/<feature>.md` + Architect's "UX Interface Boundary" section
- **Output**: `docs/ux/<feature>-journey.md` + `docs/ba/prototype/<feature>.html` (M/L mandatory)
- **Must include**: Page flow diagram, state matrix per page (Normal/Loading/Empty/Error/Edge), interaction sequence for ≥1 happy path + ≥1 error path, clickable HTML prototype with real copy
- **Rule**: Prototype must be interactive, not static. No lorem ipsum.

### Coder
- **Role**: Implementation plan, coding, self-test
- **Boundary**: Only implements what's defined in arch + UX docs. No design decisions during coding.
- **Required input**: `docs/architect/<module>.md` + `docs/ux/<feature>-journey.md` (if UI involved)
- **Output**: Plan doc `docs/coder/<feature>.md` + code changes
- **Plan must include**: Change scope (exact files/functions), ordered implementation steps with expected output per step, dependencies, self-test plan (happy path + ≥2 error cases), unknowns tagged `[?]` for PM
- **Rule**: L-level plan MUST pass Architect review before coding starts. Unknowns → ask PM, don't guess.

### Tester
- **Role**: Independent verification — write test cases, execute tests
- **Boundary**: Tests only. Does not fix bugs, only reports them.
- **Required input**: `docs/architect/<module>.md` (API defs) + `docs/ux/<feature>-journey.md` (state matrix)
- **Reference**: `docs/coder/<feature>.md` (coder's self-test plan)
- **Output**: `docs/tester/<feature>.md` + E2E code in `docs/tester/e2e/`
- **Must include**: Test case matrix (name + scenario + preconditions + steps + expected + actual), classification: [Code-Verifiable] vs [Needs-Human], bugs with severity + reproduction steps, regression checklist
- **Rule**: MUST actually execute tests. Cannot infer results from reading code. System API / permission / external service cases → tag [Needs-Human].

---

## Skill Mapping per Worker

| Worker | Skills to Load |
|--------|---------------|
| **BA** | None specific — core skill is structured Q&A |
| **Architect** | `architect`, `planner`, `api-design`, `database-reviewer`, `security-review`, `documentation-lookup` |
| **UX** | `frontend-patterns`, `design-system`, `accessibility`, `ui-demo` |
| **Coder** | `planner`, `tdd-guide`, `code-reviewer` + language-specific reviewer |
| **Tester** | `e2e-testing`, `browser-qa`, `benchmark`, `security-review` |
