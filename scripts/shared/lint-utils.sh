#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : lint-utils.sh
# Purpose: Run linting checks on utility scripts and shared modules
#          to enforce style, syntax, and security standards
# Location: scripts/shared/
# Usage   : bash scripts/shared/lint-utils.sh
# Notes   : Uses ShellCheck and custom rules for modular validation.
#           Designed for CI pipelines and local pre-flight checks.
# ─────────────────────────────────────────────────────────────

source scripts/shared/check-core.sh

run_linter_check() {
  # Wrapper for linter-specific checks
  run_check "$1" "$2" "$3" "$4"
}
