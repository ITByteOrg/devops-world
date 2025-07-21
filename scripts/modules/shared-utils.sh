#!/bin/bash
# --------------------------------------------------------------------
# File: Shared-Utils.sh
# Purpose: Reusable Bash utilities for logging and console output.
#          Mirrors Shared-Utils.psm1 for visual consistency.
#
# Functions:
#   echo-StdLog "message" error|warn|info|success
#     - Outputs colored log with severity tag
#     - Defaults to unstyled [LOG] if type is missing or unknown
#
# Usage:
#    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#    source "$SCRIPT_DIR/../modules/shared-utils.sh"
# --------------------------------------------------------------------

# ── ANSI color codes
COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;34m"
COLOR_WARN="\033[1;33m"
COLOR_ERROR="\033[1;31m"
COLOR_SUCCESS="\033[1;32m"

# ── Log wrapper to mirror Write-StdLog
echo-StdLog() {
  local message="$1"
  local type="${2,,}"  # normalize casing

  case "$type" in
    "error")   echo -e "${COLOR_ERROR}$message${COLOR_RESET}" ;;
    "warn")    echo -e "${COLOR_WARN}$message${COLOR_RESET}" ;;
    "info")    echo -e "${COLOR_INFO}$message${COLOR_RESET}" ;;
    "success") echo -e "${COLOR_SUCCESS}$message${COLOR_RESET}" ;;
    "raw")     echo -e "$message" ;;  # ✨ plain line, no tag or color
    "")        echo ;;                # ✨ blank line
    *)         echo -e "[LOG] $message" ;;
  esac
}

