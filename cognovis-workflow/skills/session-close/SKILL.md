---
name: session-close
model: sonnet
description: >-
  Session close protocol: close beads, commit, changelog, CalVer tag, doc-check, git push.
  Use when ending a session, releasing, or creating a versioned checkpoint.
  Triggers on session-close, session close, release, rc, session beenden.
disableModelInvocation: true
---

# Session Close Protocol

Orchestrates a full session close: beads cleanup, conventional commit, changelog generation,
CalVer versioning, documentation gap detection, and git push.

## When to Use

- End of a productive session — capture all outcomes
- Creating a versioned release checkpoint
- User says "session close", "release", or "rc"

## Usage

```
/session-close            # Interactive full workflow
/session-close --dry-run  # Preview what would happen, no changes
/session-close --skip-push       # Do everything except git push
```

## Workflow Steps

Each step can fail gracefully without blocking the next.

### Step 1: Beads Review

Check for open/in-progress beads and interactively close them.

```bash
${CLAUDE_SKILL_DIR}/handlers/beads-close.sh
```

For each in-progress bead, ask the user:
- **Close** with reason -> `bd close <id> --reason="..."`
- **Leave open** -> skip
- **Update status** -> `bd update <id> --status=...`

### Step 1.5: Plan Cleanup

Scan for bead-ID-named plan files where the bead is already closed:
```bash
# For each plans/<name>.md where <name> matches bead ID pattern:
# Check bd show <name> status
# If closed or not found → delete the plan file
```

Skip silently if no plan files exist.

### Step 2: Git Status Review

Show `git status` and `git diff --stat` so the user can review uncommitted changes.
If there are unstaged changes, ask the user which files to stage.

### Step 3: Conventional Commit

Build a conventional commit message interactively:
1. Determine type: `feat`, `fix`, `refactor`, `docs`, `chore`, etc.
2. Optional scope (skill name, component, etc.)
3. Short description (imperative, lowercase)
4. Optional body for details
5. Execute: `git add` + `git commit`

### Step 4: Changelog Generation

Run `git-cliff` to generate/update CHANGELOG.md from commits since the last tag.

```bash
${CLAUDE_SKILL_DIR}/handlers/changelog.sh [--dry-run]
```

If CHANGELOG.md was updated, stage it and amend or create a follow-up commit.

### Step 5: CalVer Version Tag

Determine the next version and create a git tag.

```bash
${CLAUDE_SKILL_DIR}/handlers/version.sh [--dry-run]
```

Format: `vYYYY.0M.MICRO` (e.g., `v2026.02.0`, `v2026.02.1`).
MICRO increments within the same month, resets to 0 on new month.

### Step 6: Documentation Gap Check

Scan for changed files that may need documentation updates.

```bash
${CLAUDE_SKILL_DIR}/handlers/docs-check.sh
```

This is advisory — the user decides whether to act on it.

### Step 7: Push + Sync

If not `--skip-push`:
1. `git push origin <branch>`
2. `git push origin <tag>`
3. `bd dolt commit` + `bd dolt push`

### Step 8: Summary

Print a summary of everything that happened:
- Beads closed
- Commit hash + message
- Version tag created
- Changelog updated (Y/N)
- Doc gaps found
- Push status

## Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | Preview all steps, no git changes |
| `--skip-push` | Skip git push + bd dolt commit/push (Step 7) |
| `--skip-beads` | Skip beads review (Step 1) |

## Do NOT

- Do NOT create tags without a commit.
- Do NOT skip the interactive commit message.
- Do NOT auto-close beads without user confirmation.
- Do NOT run changelog generation before the commit.

## Handler Scripts

All handlers are in `handlers/` and can be run standalone:

- `handlers/changelog.sh` — git-cliff wrapper, updates CHANGELOG.md
- `handlers/version.sh` — CalVer next-version calculation + tag creation
- `handlers/docs-check.sh` — Documentation gap detection
- `handlers/beads-close.sh` — Interactive beads closing workflow
