#!/bin/bash
# --------------------------------------------------------------------
# Script: trufflehog_wrapper.sh
# Purpose: Wrapper around TruffleHog for filesystem-based secret scanning
#          with Docker, logging, verbosity, and optional summary output.
#
# Requirements:
#   - Docker must be installed and running
#   - TruffleHog image: ghcr.io/trufflesecurity/trufflehog:latest
#   - Exclude file with regex patterns (e.g., .trufflehog-exclude.txt)
#
# Output:
#   - JSON scan results to logs/trufflehog_scan.json
#   - Summary counts to logs/trufflehog_summary.txt
#
# Example usage:
#   ./trufflehog_wrapper.sh --verbose
#   ./trufflehog_wrapper.sh --log logs/trufflehog_scan.json
#   ./trufflehog_wrapper.sh --dry-run
#   ./trufflehog_wrapper.sh --dir /pwd/scripts --exclude /pwd/custom_exclude.txt
#
# Flags:
#   --verbose       Show detailed execution info
#   --dry-run       Preview Docker command without running scan
#   --dir <path>    Directory to scan (default: /pwd)
#   --exclude <file>   Path to regex-based exclude file (default: /pwd/.trufflehog-exclude.txt)
#   --log <file>    Path to save raw JSON scan output (default: logs/trufflehog_scan.json)
# --------------------------------------------------------------------

set -euo pipefail

# Default values
SCAN_DIR="/pwd"
EXCLUDE_FILE="/pwd/.trufflehog-exclude.txt"
TRUFFLEHOG_IMAGE="ghcr.io/trufflesecurity/trufflehog:latest"
DRY_RUN=false
VERBOSE=false
LOG_FILE=""
RAW_OUTPUT="logs/trufflehog_scan.json"

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --verbose) VERBOSE=true ;;
    --dir) shift; SCAN_DIR="$1" ;;
    --exclude) shift; EXCLUDE_FILE="$1" ;;
    --log) shift; LOG_FILE="$1" ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
  shift
done

# Verbose output
if [[ "$VERBOSE" == "true" ]]; then
  echo "=== TruffleHog Wrapper ==="
  echo "Scan Directory: $SCAN_DIR"
  echo "Exclude File:   $EXCLUDE_FILE"
  echo "Docker Image:   $TRUFFLEHOG_IMAGE"
  echo "Dry Run:        $DRY_RUN"
  [[ -n "$LOG_FILE" ]] && echo "Log File:       $LOG_FILE"
fi

# Validate exclude file exists
if [[ ! -f "$(pwd)/$(basename "$EXCLUDE_FILE")" ]]; then
  echo "Error: Exclude file not found: $EXCLUDE_FILE"
  exit 1
fi

mkdir -p "$PWD/logs"

# Dry run preview
if [[ "$DRY_RUN" == "true" ]]; then
  echo "--- Dry Run ---"
  echo "Would execute:"
  echo "docker run --rm -v \"\$PWD:/pwd\" --entrypoint trufflehog $TRUFFLEHOG_IMAGE filesystem \"$SCAN_DIR\" --exclude_paths \"$EXCLUDE_FILE\" --json"
  [[ -n "$LOG_FILE" ]] && echo "Output would be logged to: $LOG_FILE"
  exit 0
fi

# Run scan and capture output
docker run --rm -v "$PWD:/pwd" \
  --entrypoint trufflehog \
  "$TRUFFLEHOG_IMAGE" \
  filesystem "$SCAN_DIR" \
  --exclude_paths "$EXCLUDE_FILE" \
  --json \
  > "$RAW_OUTPUT"

# Optional file logging
if [[ -n "$LOG_FILE" && "$RAW_OUTPUT" != "$LOG_FILE" ]]; then
  cp "$RAW_OUTPUT" "$LOG_FILE"
else
  echo "Skipping redundant copy — log file already in target location"
fi

if [[ -s "$RAW_OUTPUT" ]]; then
  UNVERIFIED=$(jq '[.[] | select(.verified==false)] | length' "$RAW_OUTPUT")
  VERIFIED=$(jq '[.[] | select(.verified==true)] | length' "$RAW_OUTPUT")

  echo "--- Summary ---"
  echo "Verified: $VERIFIED" > logs/trufflehog_summary.txt
  echo "Unverified: $UNVERIFIED" >> logs/trufflehog_summary.txt
  echo "![Secrets](https://img.shields.io/badge/Unverified_$UNVERIFIED-red)" > logs/trufflehog_badge.md
else
  echo "--- Summary ---" > logs/trufflehog_summary.txt
  echo "[OK] No secrets found. Scan output file is empty." >> logs/trufflehog_summary.txt
  echo "![Secrets](https://img.shields.io/badge/Unverified_0-green)" > logs/trufflehog_badge.md
fi
