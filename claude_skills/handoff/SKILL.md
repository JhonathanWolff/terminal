---
name: handoff
description: create or updated HANDOFF.md for the next agent or a clean context
disable-model-invocation: true
---

Write or update a handoff document so the next agent, starting with zero context, can continue this work without re-exploring or repeating mistakes.

## Steps

1. Find the project root (`git rev-parse --show-toplevel`, or the current directory if not a git repo).
2. If `HANDOFF.md` exists there, read it first to understand prior context.
3. Gather the current state: `git status`, `git branch --show-current`, `git log --oneline -5`, and the result of the last test/build run in this session.
4. Write `HANDOFF.md` using the template below. When updating, **rewrite** it to reflect the current state: remove what is stale or resolved, keep what is still true. It is a snapshot, not a log.
5. Tell the user the absolute file path so they can start a fresh conversation with just that path.

## Template

```markdown
# Handoff: <short title>

_Updated: <YYYY-MM-DD>_

## Goal
What we're trying to accomplish and why. The definition of done.

## Current State
- Branch: `<branch>` — uncommitted changes: <yes/no, which files>
- Tests/build: <passing | failing: exact error | not run>

## Current Progress
What's been done so far.

## Key Files
- `path/to/file` — role in this work / what changed

## Decisions
- <decision> — why (and the alternative rejected)

## What Worked
Approaches that succeeded.

## What Didn't Work
Approaches that failed and why, so they're not repeated. Include exact error messages.

## Blockers / Open Questions
Anything that depends on the user or is still undecided.

## Next Steps
1. <first action, doable immediately>
2. ...

## How to Verify
Commands to run, test, or reproduce.
```

## Rules

- Be specific: exact paths, commands, error messages, function names. Never "adjusted the function".
- Write only what a fresh agent can't cheaply discover from the code or git history.
- Omit a section only if it genuinely has nothing (write "None" for Blockers rather than dropping it).
- Keep it concise; a handoff that's too long is as useless as an incomplete one.
- Write in the same language the user uses in the conversation.
