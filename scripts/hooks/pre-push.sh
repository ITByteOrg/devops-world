#!/usr/bin/env bash
# --------------------------------------------------------------------
# File: pre-push.sh
#
# Description:
#   Git pre-push hook to scan pushed commits for sensitive secrets
#   using TruffleHog logic. Prevents accidental leakage by blocking
#   pushes containing flagged content.
#
# Dependencies:
#   - shared-utils.sh: provides logging functions (write_stdlog)
#   - TruffleHogHookScanner.sh: performs the actual secret scan
#
# Usage:
#   Place in .git/hooks/pre-push (or symlink if using core.hooksPath)
#
# Environment:
#   CI-aware: outputs adapt based on terminal detection
# --------------------------------------------------------------------

# Resolve paths
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"
source "$GIT_ROOT/scripts/modules/trufflehoghookscanner.sh"

# Execute scan
if ! scan_with_trufflehog; then
  write_stdlog "Secret detected — push blocked!" error
  exit 1
fi

write_stdlog "Push clean — no secrets found." success
exit 0
