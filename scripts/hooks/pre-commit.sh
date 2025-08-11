#!/usr/bin/env bash
# --------------------------------------------------------------------
# File: pre-commit.sh
#
# Description:
#   Git pre-commit hook for scanning staged changes with TruffleHog.
#   Blocks commits containing high-entropy secrets or leaked credentials.
#   Emits color-coded log messages to terminal via shared-utils.sh.
#
# Dependencies:
#   shared-utils.sh, TruffleHogHookScanner.sh  
# --------------------------------------------------------------------

# Resolve paths
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"
source "$GIT_ROOT/scripts/modules/trufflehoghookscanner.sh"

# Run secret scan
if ! run_trufflehog_scan; then
  write_stdlog "Secret detected — blocking commit!" error
  exit 1
fi

write_stdlog "No secrets found — commit approved." success
exit 0
