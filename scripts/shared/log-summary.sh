#!/usr/bin/env bash

# Usage:
# bash log-summary.sh --title "Fix Summary" --status "✅ Success" --actions "✔ Imports sorted,✔ Code formatted" --output "logs/fix-summary.md"
#
# Example:
# bash scripts/shared/log-summary.sh \
#  --title "Check Summary" \
# --status "All validations passed" \
# --actions "Lint check completed,\
# --output "logs/check-summary.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) TITLE="$2"; shift 2 ;;
    --status) STATUS="$2"; shift 2 ;;
    --actions) ACTIONS="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

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



