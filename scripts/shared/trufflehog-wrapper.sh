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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../modules/shared-utils.sh"

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
    *) echo-StdLog "Unknown argument: $1" error; exit 1 ;;
  esac
  shift
done

# Verbose output
if [[ "$VERBOSE" == "true" ]]; then
  echo-StdLog "=== TruffleHog Wrapper ===" raw
  echo-StdLog "Scan Directory: $SCAN_DIR" raw
  echo-StdLog "Exclude File:   $EXCLUDE_FILE" raw
  echo-StdLog "Docker Image:   $TRUFFLEHOG_IMAGE" raw
  echo-StdLog "Dry Run:        $DRY_RUN" raw
  [[ -n "$LOG_FILE" ]] && echo-StdLog "Log File:       $LOG_FILE" info
fi

# Validate exclude file exists
if [[ ! -f "$(pwd)/$(basename "$EXCLUDE_FILE")" ]]; then
  echo-StdLog "[Error] Exclude file not found: $EXCLUDE_FILE" error
  exit 1
fi

mkdir -p "$PWD/logs"

# Dry run preview
if [[ "$DRY_RUN" == "true" ]]; then
  echo-StdLog "--- Dry Run ---" info
  echo-StdLog "Would execute:" info
  echo-StdLog "docker run --rm -v \"\$PWD:/pwd\" --entrypoint trufflehog $TRUFFLEHOG_IMAGE filesystem \"$SCAN_DIR\" --exclude_paths \"$EXCLUDE_FILE\" --json" info
  [[ -n "$LOG_FILE" ]] && echo-StdLog "Output would be logged to: $LOG_FILE" info
  exit 0
fi

docker run --rm -v "$PWD:/pwd" \
  --entrypoint trufflehog \
  "$TRUFFLEHOG_IMAGE" \
  filesystem "$SCAN_DIR" \
  --exclude_paths "$EXCLUDE_FILE" \
  --json \
  > "$RAW_OUTPUT" 2> logs/trufflehog_error.log

# Optional file logging
if [[ -n "$LOG_FILE" && "$RAW_OUTPUT" != "$LOG_FILE" ]]; then
  cp "$RAW_OUTPUT" "$LOG_FILE"
else
  echo-StdLog "Skipping redundant copy — log file already in target location" info
fi

# if file in $RAW_OUTPUT exists and size gt 0
if [[ -s "$RAW_OUTPUT" ]]; then
  
  # does not have valid JSON
  if ! jq empty "$RAW_OUTPUT" &>/dev/null; then
    echo "--- Summary ---" > logs/trufflehog_summary.txt
    echo "[ERROR] Scan output is malformed or empty." >> logs/trufflehog_summary.txt
    echo "![Secrets](https://img.shields.io/badge/TruffleHog_Scan_Failed-red)" > logs/trufflehog_badge.md
    exit 1
  else # contains valid JSON
    UNVERIFIED=$(jq '[.[] | select(.verified==false)] | length' "$RAW_OUTPUT")
    VERIFIED=$(jq '[.[] | select(.verified==true)] | length' "$RAW_OUTPUT")

    echo "--- Summary ---" > logs/trufflehog_summary.txt
    echo "Verified: $VERIFIED" > logs/trufflehog_summary.txt
    echo "Unverified: $UNVERIFIED" >> logs/trufflehog_summary.txt
    echo "![Secrets](https://img.shields.io/badge/Unverified_$UNVERIFIED-red)" > logs/trufflehog_badge.md
  fi
else  # file doesn't exist
  echo "--- Summary ---" > logs/trufflehog_summary.txt
  echo "[OK] No secrets found. Scan output file is empty." >> logs/trufflehog_summary.txt
  echo "![Secrets](https://img.shields.io/badge/Unverified_0-green)" > logs/trufflehog_badge.md
fi
