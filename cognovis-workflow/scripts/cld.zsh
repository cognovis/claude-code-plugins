#!/usr/bin/env zsh
# cld - Claude Code launcher with beads workflow integration
#
# Usage: cld [--skip-perms] [--force-check] [--no-check] [-v|--verbose] [-b|--bead ID] [-bp|--plan-label LABEL] [claude-args...]
#
# Wrapper flags (not passed to claude):
#   --skip-perms    → translates to --dangerously-skip-permissions
#   --force-check   → force update check even if cache is fresh
#   --no-check      → skip update check entirely
#   -v, --verbose   → enable verbose mode (reasoning traces + token counts)
#   -b, --bead ID   → launch with bead orchestrator for the given bead ID
#   -bp, --plan-label LABEL → launch with /plan --label LABEL as initial prompt
#
# Optional: claude-updater (uv tool install claude-updater) for pre-launch update checks

set -uo pipefail

# Auto-detect claude binary
CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude 2>/dev/null)}"
if [[ -z "${CLAUDE_BIN}" ]]; then
    echo "ERROR: claude not found in PATH. Install Claude Code first."
    exit 1
fi

# ── Parse wrapper flags ──────────────────────────────────────────

skip_perms=false
force_check=false
no_check=false
verbose=false
bead_id=""
plan_label=""
claude_args=()

while (( $# > 0 )); do
    case "$1" in
        --skip-perms)
            skip_perms=true
            shift
            ;;
        --force-check)
            force_check=true
            shift
            ;;
        --no-check)
            no_check=true
            shift
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -b|--bead)
            bead_id="$2"
            shift 2
            ;;
        -bp|--plan-label)
            plan_label="$2"
            shift 2
            ;;
        *)
            claude_args+=("$1")
            shift
            ;;
    esac
done

# Build final claude args — always use --dangerously-skip-permissions
claude_args=("--dangerously-skip-permissions" "${claude_args[@]}")

if ${verbose}; then
    claude_args=("--verbose" "${claude_args[@]}")
fi

if [[ -n "$bead_id" ]]; then
    # ── Worktree isolation via Claude Code native --worktree ──────
    local worktree_name="bead-${bead_id}"
    claude_args+=("--worktree" "$worktree_name")
    claude_args+=("--agent" "bead-orchestrator")

    # ── Set terminal tab title to bead ID ───────────────────────
    printf '\033]1;%s\033\\' "$bead_id"
    printf '\033]2;%s\033\\' "cld: $bead_id"

    # ── Derive namespace from bead prefix + number ───────────────
    local bead_ns=""
    local bead_prefix
    bead_prefix=$(bd config get issue_prefix 2>/dev/null)
    if [[ -n "$bead_prefix" ]]; then
        local bead_num="${bead_id##*-}"
        bead_ns="${bead_prefix}-${bead_num}"
    fi

    local prompt="You are the bead-orchestrator agent. Bead ID: $bead_id. Run your Phase 0–5 workflow as defined in your agent instructions. Do NOT invoke the /beads skill — you ARE the orchestrator."

    if [[ -n "$bead_ns" ]]; then
        prompt+=" Portless namespace: $bead_ns (use as namespace when starting dev servers, e.g. for portless-based setups)."
    fi

    claude_args+=("$prompt")
fi

if [[ -n "$plan_label" ]]; then
    claude_args+=("/plan --label $plan_label")
fi

# ── Update check via claude-updater (optional) ───────────────────

if ! ${no_check}; then
    if command -v claude-updater &>/dev/null; then
        if ${force_check}; then
            claude-updater check --force 2>&1
        else
            claude-updater check 2>&1
        fi
    fi
fi

# ── Launch claude ────────────────────────────────────────────────
exec "${CLAUDE_BIN}" "${claude_args[@]}"
