# Cognovis Claude Code Plugins

Claude Code plugin marketplace for Cognovis projects.

## Installation

```bash
# Add marketplace
/plugin marketplace add cognovis/claude-code-plugins

# Browse plugins
/plugin

# Install workflow plugin
/plugin install cognovis-workflow@cognovis-claude-code-plugins
```

## Available Plugins

### cognovis-workflow (v1.0.0)

Beads-based workflow skills for structured software development.

| Component | Description |
|-----------|-------------|
| `/epic-init` | Guided epic planning with duplicate detection and break analysis |
| `/beads <id>` | Autonomous bead implementation with sizing, TDD, and verification |
| `/session-close` | Session end protocol: close beads, commit, changelog, CalVer tag, push |
| `cld` launcher | Shell wrapper with `-b <bead-id>` for worktree-isolated bead work |

**Prerequisites:** [beads](https://github.com/steveyegge/beads), [git-cliff](https://github.com/orhun/git-cliff), Dolt

See [cognovis-workflow/README.md](./cognovis-workflow/README.md) for details.

## License

Proprietary - Cognovis GmbH
