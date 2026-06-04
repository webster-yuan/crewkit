# Skill Scouting Protocol

## When to Scout

Before dispatching ANY Worker (BA, Architect, UX, Coder, Tester), run skill-scout
to match the task + project context to relevant skills.

## How

```
1. Read project fingerprint: CLAUDE.md / AGENTS.md / package.json
2. Extract task keywords from Worker's assignment
3. skill-scout matches → returns top 3-8 skills
4. Load matched skills via skill_view() before Worker starts
```

## Per-Role Default Skills

| Role | Always Load |
|------|------------|
| PM | crewkit, skill-scout |
| BA | crewkit, writing-plans |
| Architect | crewkit, architecture-decision-records, api-design |
| UX | crewkit, design-system, frontend-patterns |
| Coder | coding-standards, git-workflow, tdd-workflow |
| Tester | e2e-testing, systematic-debugging |
| Debug (any) | forensic-bisect |
