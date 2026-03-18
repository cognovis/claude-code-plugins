#!/usr/bin/env bash
# version.sh - CalVer versioning: determine next version, update VERSION file, create tag
# Usage: version.sh [--dry-run]
#
# Delegates version calculation to scripts/next-version.sh (infrastructure).
# CalVer format: YYYY.0M.MICRO (e.g., 2026.02.0, 2026.02.1, 2026.03.0)

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
VERSION_FILE="$REPO_ROOT/VERSION"
NEXT_VERSION_SCRIPT="$REPO_ROOT/scripts/next-version.sh"

# Show current state
LATEST_TAG=$(git -C "$REPO_ROOT" tag --list "v[0-9]*.[0-9]*.[0-9]*" --sort=-v:refname 2>/dev/null | head -1)
if [ -n "$LATEST_TAG" ]; then
  echo "Latest tag: $LATEST_TAG"
else
  echo "No previous version tags found."
fi

# Determine next version
if [ -x "$NEXT_VERSION_SCRIPT" ]; then
  NEXT_VERSION=$(bash "$NEXT_VERSION_SCRIPT")
elif [ -f "$NEXT_VERSION_SCRIPT" ]; then
  NEXT_VERSION=$(bash "$NEXT_VERSION_SCRIPT")
else
  # Fallback: inline calculation if script is missing
  YEAR=$(date +%Y)
  MONTH=$(date +%m)
  TAG_PREFIX="v${YEAR}.${MONTH}"
  MONTH_TAG=$(git -C "$REPO_ROOT" tag --list "${TAG_PREFIX}.*" --sort=-v:refname 2>/dev/null | head -1)
  if [ -n "$MONTH_TAG" ]; then
    CURRENT_MICRO=$(echo "$MONTH_TAG" | sed "s/^${TAG_PREFIX}\\.//")
    NEXT_MICRO=$((CURRENT_MICRO + 1))
  else
    NEXT_MICRO=0
  fi
  NEXT_VERSION="${YEAR}.${MONTH}.${NEXT_MICRO}"
  echo "(using fallback version calculation -- scripts/next-version.sh not found)"
fi

NEXT_TAG="v${NEXT_VERSION}"

echo "Next version: $NEXT_VERSION"
echo "Next tag: $NEXT_TAG"

if $DRY_RUN; then
  echo ""
  echo "[DRY-RUN] Would write $NEXT_VERSION to $VERSION_FILE"
  echo "[DRY-RUN] Would create git tag $NEXT_TAG"
else
  # Write VERSION file
  echo "$NEXT_VERSION" > "$VERSION_FILE"
  echo "VERSION file updated: $NEXT_VERSION"
  git -C "$REPO_ROOT" add "$VERSION_FILE"

  # Create annotated tag
  git -C "$REPO_ROOT" tag -a "$NEXT_TAG" -m "Release $NEXT_VERSION"
  echo "Tag created: $NEXT_TAG"
fi
