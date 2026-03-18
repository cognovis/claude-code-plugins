# Cognovis Workflow Plugin

Beads workflow skills for Cognovis projects. Provides structured epic planning, autonomous bead implementation, session close protocol, and a launcher with update checking.

## Installation

### Via Marketplace (recommended)

```bash
# Add the Cognovis marketplace
/plugin marketplace add cognovis/claude-code-plugins

# Install the workflow plugin
/plugin install cognovis-workflow@cognovis-claude-code-plugins
```

### Manual

```bash
# Copy components to Claude Code config
cp -r skills/ ~/.claude/skills/
cp -r agents/ ~/.claude/agents/

# Install the cld launcher
cp scripts/cld.zsh /usr/local/bin/cld
# Or: ln -s $(pwd)/scripts/cld.zsh /usr/local/bin/cld
```

## Prerequisites

- [beads](https://github.com/steveyegge/beads) (`bd`) installed and initialized in your project
- [git-cliff](https://github.com/orhun/git-cliff) for changelog generation (session-close)
- Dolt remote configured for beads sync
- Optional: [claude-updater](https://pypi.org/project/claude-updater/) for pre-launch update checks

```bash
# Install prerequisites
brew install beads dolt git-cliff

# Optional: update checker
uv tool install claude-updater
```

## Components

### `cld` — Claude Code Launcher

Wrapper that adds beads workflow integration to Claude Code.

**macOS/Linux (ZSH):**
```bash
cld                          # Launch Claude Code (with optional update check)
cld -b <bead-id>             # Launch bead orchestrator in isolated worktree
cld -b <bead-id> -v          # Same, with verbose output
cld --skip-perms             # Launch with --dangerously-skip-permissions
cld --no-check               # Skip update check
```

**Windows (PowerShell):**
```powershell
.\cld.ps1                    # Launch Claude Code
.\cld.ps1 -b <bead-id>      # Launch bead orchestrator in isolated worktree
.\cld.ps1 -b <bead-id> -v   # Same, with verbose output
.\cld.ps1 -SkipPerms         # Launch with --dangerously-skip-permissions
.\cld.ps1 -NoCheck           # Skip update check
```

**Without wrapper (any OS):**
```bash
claude --worktree bead-<ID> --agent bead-orchestrator "Bead ID: <ID>. Execute the full orchestration workflow (Phase 0-5)."
```

The `-b` flag:
- Creates an isolated git worktree for the bead
- Launches the bead-orchestrator agent automatically
- Sets the terminal tab title to the bead ID
- Derives a clean namespace from the bead prefix for dev servers

### `/epic-init` — Epic Planning

Guided dialog for breaking larger initiatives into beads epics with sub-tasks.

```
/epic-init                              # Interactive dialog
/epic-init "FHIR Patient Intake"        # Start with goal
```

Features:
- Automatic duplicate detection against existing beads
- Break analysis (pre-mortem) before creating beads
- Dependency mapping between sub-tasks

### `/beads` — Bead Orchestrator

Autonomous implementation orchestrator. Analyzes a bead, optionally slices it, spawns implementation subagents, verifies results, and closes.

```
/beads <bead-id>                # Full orchestration
/beads <bead-id> --dry-run      # Sizing analysis only
/beads <bead-id> --skip-tests   # Skip test phase
```

Workflow: Sizing → Claim → Context → Break Analysis → Implementation → Verification → Close

### `/session-close` — Session Close Protocol

Structured session end: close beads, conventional commit, changelog, CalVer tag, push.

```
/session-close                  # Full workflow
/session-close --dry-run        # Preview only
/session-close --skip-push      # No git push
```

## File Structure

```
cognovis-workflow/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── bead-orchestrator.md
├── scripts/
│   ├── cld.zsh              # macOS/Linux launcher
│   └── cld.ps1              # Windows launcher
├── skills/
│   ├── epic-init/
│   │   └── SKILL.md
│   ├── beads/
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── sizing.md
│   └── session-close/
│       ├── SKILL.md
│       └── handlers/
│           ├── beads-close.sh
│           ├── changelog.sh
│           ├── docs-check.sh
│           └── version.sh
└── README.md
```
