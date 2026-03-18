---
name: beads
model: sonnet
description: >-
  Orchestrate bead implementation with sizing, slicing, and TDD via subagent workflows.
  Use when implementing beads, slicing oversized beads, or continuing bead work.
  Triggers on implementiere bead, arbeite an bead, slice bead, bead zu gross.
---

# Beads Dispatcher

**Rules:** Never use `bd edit`. Never guess bead ID prefixes — `bd show 9yt` works with the hash only.

## Dispatch Table

| ARGUMENTS | Action |
|-----------|--------|
| `<bead-id>` | Spawn `bead-orchestrator` agent |
| `<bead-id> --dry-run` | Spawn orchestrator with `--dry-run` |
| `<bead-id> --skip-tests` | Spawn orchestrator with `--skip-tests` |
| `<bead-id> --skip-slicing` | Spawn orchestrator with `--skip-slicing` |
| *(empty)* | Run `bd ready`, show results, let user pick |

## If bead ID in ARGUMENTS

Spawn a `general-purpose` agent with this prompt:

```
Read ${CLAUDE_PLUGIN_ROOT}/agents/bead-orchestrator.md for your workflow instructions.

Bead ID: {BEAD_ID}
Flags: {FLAGS}

Execute the full orchestration workflow (Phase 0–5) for this bead.
```

## If ARGUMENTS is empty

Run `bd ready` and show results. Prompt: "Which bead? Run `/beads <id>` to start."
