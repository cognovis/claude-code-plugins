<#
.SYNOPSIS
    Claude Code launcher with beads workflow integration.
.EXAMPLE
    cld                          # Launch Claude Code
    cld -b <bead-id>             # Launch bead orchestrator in isolated worktree
    cld -b <bead-id> -v          # Same, with verbose output
    cld -SkipPerms               # Launch with --dangerously-skip-permissions
    cld -NoCheck                 # Skip update check
    cld -ForceCheck              # Force update check (ignore cache)
#>
param(
    [Alias("b")][string]$Bead,
    [Alias("v")][switch]$VerboseOutput,
    [switch]$SkipPerms,
    [switch]$ForceCheck,
    [switch]$NoCheck,
    [string]$PlanLabel,
    [Parameter(ValueFromRemainingArguments)][string[]]$ClaudeArgs
)

$ErrorActionPreference = "Stop"

# Find claude binary
$claudeBin = if ($env:CLAUDE_BIN) { $env:CLAUDE_BIN } else { (Get-Command claude -ErrorAction SilentlyContinue).Source }
if (-not $claudeBin) {
    Write-Error "claude not found in PATH. Install Claude Code first."
    exit 1
}

$args_ = [System.Collections.ArrayList]::new()

# Always use --dangerously-skip-permissions unless explicitly disabled
[void]$args_.Add("--dangerously-skip-permissions")

if ($VerboseOutput) {
    [void]$args_.Add("--verbose")
}

if ($Bead) {
    $worktreeName = "bead-$Bead"
    [void]$args_.Add("--worktree")
    [void]$args_.Add($worktreeName)
    [void]$args_.Add("--agent")
    [void]$args_.Add("bead-orchestrator")

    # Set terminal title
    $Host.UI.RawUI.WindowTitle = "cld: $Bead"

    # Derive namespace from bead prefix
    $beadNs = ""
    $beadPrefix = & bd config get issue_prefix 2>$null
    if ($beadPrefix) {
        $beadNum = ($Bead -split "-")[-1]
        $beadNs = "$beadPrefix-$beadNum"
    }

    $prompt = "You are the bead-orchestrator agent. Bead ID: $Bead. Run your Phase 0-5 workflow as defined in your agent instructions. Do NOT invoke the /beads skill - you ARE the orchestrator."
    if ($beadNs) {
        $prompt += " Portless namespace: $beadNs (use as namespace when starting dev servers, e.g. for portless-based setups)."
    }

    [void]$args_.Add($prompt)
}

if ($PlanLabel) {
    [void]$args_.Add("/plan --label $PlanLabel")
}

if ($ClaudeArgs) {
    $ClaudeArgs | ForEach-Object { [void]$args_.Add($_) }
}

# Update check (optional)
if (-not $NoCheck) {
    $updater = Get-Command claude-updater -ErrorAction SilentlyContinue
    if ($updater) {
        if ($ForceCheck) {
            & claude-updater check --force 2>&1
        } else {
            & claude-updater check 2>&1
        }
    }
}

# Launch claude
& $claudeBin @args_
