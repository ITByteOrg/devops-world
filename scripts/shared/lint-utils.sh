#!/usr/bin/env bash
# lint-utils.sh
# Shared helpers for linting and validation tasks

source scripts/shared/check-core.sh

run_linter_check() {
  # Wrapper for linter-specific checks
  run_check "$1" "$2" "$3" "$4"
}
