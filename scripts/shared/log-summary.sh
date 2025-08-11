#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : log-summary.sh
# Purpose: Summarize log outputs from CI runs, hook executions,
#          or local scans into a readable format
# Location: scripts/shared/
# Usage   : bash scripts/shared/log-summary.sh
# Notes   : Parses standardized log entries and outputs summary
#           for visibility in CI dashboards or local review.
# ─────────────────────────────────────────────────────────────

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --actions) ACTIONS="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

write_stdlog "$TITLE complete. " raw

{
  echo "# $TITLE"
  echo ""
  echo "**Status:** $STATUS"
  echo ""
  echo "### Checks"
  echo ""
  
  # Split comma-delimited actions into separate lines
  IFS=',' read -ra action_array <<< "$ACTIONS"
  for act in "${action_array[@]}"; do
    echo "- $act"
  done

  echo ""
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  COMMIT=$(git rev-parse --short HEAD)
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M %Z")

  echo "Metadata:" >> "$OUTPUT"
  echo "- Branch: $BRANCH" >> "$OUTPUT"
  echo "- Commit: $COMMIT" >> "$OUTPUT"
  echo "- Timestamp: $TIMESTAMP" >> "$OUTPUT"

} > "$OUTPUT"



