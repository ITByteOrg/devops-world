#!/usr/bin/env bash

# --------------------------------------------------------------------
# File: testanything.sh
# Purpose: run any test
# Usage: bash tests/testanything.sh
# --------------------------------------------------------------------

set -euo pipefail  # Exit on error, treat unset vars as errors, fail on pipe errors

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

echo "🔍 Testing write_log for all types..."

types=("info" "warn" "error" "success" "ok" "debug" "unknown")

for type in "${types[@]}"; do
  write_log "$type" "This is a test message for type '$type'", "$GIT_ROOT/logs" "custom.log"
done

for type in "${types[@]}"; do
  write_log "$type" "Default log name matches script" "$GIT_ROOT/logs" 
done

echo "🔍 Testing write_stdlog for all types..."
for type in "${types[@]}"; do
  write_stdlog "This is a test message for type '$type'" "$type"
done