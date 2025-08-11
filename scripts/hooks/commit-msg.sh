#!/usr/bin/env bash
# File: commit-msg.sh
#
# Description:
#   Git commit-msg hook that validates commit message formatting
#   and scans the latest commit using TruffleHog.
#
# Parameters:
#   $1 - Path to the commit message file passed by Git
#
# Dependencies:
#   shared-utils.sh: for structured logging
#   TruffleHog CLI: available in PATH
#
# Usage:
#   Place in .git/hooks/commit-msg or use with core.hooksPath

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

# Input: commit message file
COMMIT_MSG_FILE="$1"

write_stdlog "Running commit-msg hook..." info

# Validate commit message file exists
if [[ ! -f "$COMMIT_MSG_FILE" ]]; then
  write_stdlog "Missing commit message file: $COMMIT_MSG_FILE" error
  exit 1
fi

# Extract commit message
COMMIT_MESSAGE="$(<"$COMMIT_MSG_FILE")"
write_stdlog "Commit message: \"$COMMIT_MESSAGE\"" info

# Format check: starts with capital letter
if [[ ! "$COMMIT_MESSAGE" =~ ^[A-Z] ]]; then
  write_stdlog "Message should start with a capital letter." warn
fi

# Retrieve latest commit hash
LATEST_COMMIT="$(git rev-parse HEAD 2>/dev/null)"
write_stdlog "Latest commit: $LATEST_COMMIT" info

# TruffleHog scan
write_stdlog "Scanning with TruffleHog..." info
TRUFFLE_OUTPUT="$(trufflehog git --commit "$LATEST_COMMIT" 2>&1)"

# Detect secret patterns
if [[ "$TRUFFLE_OUTPUT" =~ "Found [0-9]+ results" ]]; then
  write_stdlog "TruffleHog detected possible secrets!" error
  echo "$TRUFFLE_OUTPUT" >&2
  exit 1
else
  write_stdlog "TruffleHog scan passed — no secrets detected." success
fi

# Completion message
write_stdlog "commit-msg hook completed." success
exit 0
