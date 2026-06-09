# crewkit Memory System Reference

Each worker has persistent memory at `memory/roles/<role>.memory.md`. Knowledge accumulates across sessions.

## Before Dispatching

1. Read `memory/roles/<role>.memory.md` — last 3 entries
2. Read `memory/session/current-state.md` — global context
3. Inject memory summary into worker prompt as "Known Context"

## After Worker Completes

Worker must do TWO things:
1. Write `docs/pm/from-<role>/<YYYY-MM-DD>-done.md` (notify PM)
2. Append to `memory/roles/<role>.memory.md`:

```markdown## <YYYY-MM-DD> — <task summary>

### Discovered
- constraints / limitations / patterns

### Reusable
- research conclusions / code patterns / test cases

### Watch
- potential risks / unfinished items
```

## Memory Read Triggers

| Trigger | What to Read |
|---------|-------------|
| New session start | `memory/session/current-state.md` |
| Before dispatching worker | `memory/roles/<role>.memory.md` last 3 entries |
| Similar task to past work | Keyword search in memory files |
| Hit a blocker | Check `current-state.md` blocked items |

## Session Startup

Every time PM starts a new session:

1. Check `docs/pm/from-*/` for unread worker notifications
2. If unprocessed `from-<role>/<date>-done.md` → trigger next worker immediately
3. Update workflow state table
4. If any marked "Needs Supervisor Decision" → sync to Supervisor
5. Read `memory/session/current-state.md` to recover context
