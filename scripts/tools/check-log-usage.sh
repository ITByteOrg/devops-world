#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : check-log-usage.sh
# Purpose: Identify Bash scripts using write_stdlog or write-log
# Location: scripts/tools/
# Usage   : bash scripts/tools/check-log-usage.sh
# Notes   : Recursively searches for .sh files and checks for log functions.
# ─────────────────────────────────────────────────────────────

# Exit on error, unset variables trigger failure, and pipe errors are caught
set -euo pipefail

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

LOG_FUNCS=("write_stdlog" "write-log")
declare -A results=()

echo "Scanning for log function usage in Bash scripts..."

while IFS= read -r -d '' file; do
    found=""
    for func in "${LOG_FUNCS[@]}"; do
        if grep -q "$func" "$file"; then
            found+="[$func] "
        fi
    done
    results["$file"]="${found:- None found}"
done < <(
    find "$GIT_ROOT" -type f \
    \( -name "*.sh" -o -name "sh" \) \
    -not -path "*/.venv/*" \
    -print0
)

if [[ ${#results[@]} -eq 0 ]]; then
    echo "No Bash scripts found using write_stdlog or write-log."
    exit 0
fi

write_stdlog "Log usage report:" info
declare -i none_found_count=0

for file in "${!results[@]}"; do
    result="${results[$file]}"
    if [[ "$result" == *None* ]]; then
       ((none_found_count += 1))
    fi
    printf "• %-60s : %s\n" "$(basename "$file")" "$result"
done

write_stdlog "Total entries with 'None' found: $none_found_count" info
