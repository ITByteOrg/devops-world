#!/usr/bin/env bash
# --------------------------------------------------------------------
# File: shared-utils.sh
#
# Description:
#   Reusable Bash utility functions for console messaging and logging.
#   Designed for use in Git hooks and CI workflows.
#   Mirrors Shared-Utils.psm1 for cross-platform visual consistency.
#
# Functions:
#   write-stdlog <message> <type>
#     - Outputs colored message to stdout based on log type.
#     - Supports: info, warn, error, success, raw, [blank]
#
#   write-log <message> <type> [logDir]
#     - Outputs colored message to stdout.
#     - If logDir is provided, appends timestamped entry to file.
#
# Dependencies:
#   None externally. Assumes script is sourced via:
#     GIT_ROOT="$(git rev-parse --show-toplevel)"
#     source "$GIT_ROOT/scripts/modules/shared-utils.sh"
# --------------------------------------------------------------------

# ── ANSI color map for structured log types
declare -A COLOR_MAP=(
  [info]="\033[1;34m"     # Blue
  [warn]="\033[1;33m"     # Yellow
  [error]="\033[1;31m"    # Red
  [success]="\033[1;32m"  # Green
  [raw]=""                # No formatting
  [default]="\033[0m"     # Reset
)

COLOR_RESET="\033[0m"

write-stdlog() {
  # ── Minimalist terminal output with ANSI styling (stdout only)
  local message="$1"
  local raw_type="${2:-info}" # Default to 'info' if no type provided
  local type="${raw_type,,}" # Normalize type to lowercase

  local color="${COLOR_MAP[$type]:-${COLOR_MAP[default]}}"

  case "$type" in
    "raw") echo -e "$message" ;;
    "")    echo ;;            # blank line
    *)     echo -e "${color}$message${COLOR_RESET}" ;;
  esac
}


write-log() {
  # ── Full log function with optional file write
  local message="$1"
  local raw_type="${2:-info}" # Default to 'info' if no type provided
  local type="${raw_type,,}" # Normalize type to lowercase
  local log_dir="${3:-}"     # optional: log directory

  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  local color="${COLOR_MAP[$type]:-${COLOR_MAP[default]}}"

  # ── Console output
  echo -e "${color}$message${COLOR_RESET}"

  # ── Optional log file write
  if [[ -n "$log_dir" ]]; then
    mkdir -p "$log_dir"
    echo "[$timestamp][$type] $message" >> "${log_dir}/bootstrap.log"
  fi
}

trim-whitespace() {
  # Purpose: Trim leading and trailing whitespace from a string
  # Usage: trimmed=$(trim-whitespace "$input_string")
  local input="$1"

  # Remove leading and trailing whitespace using parameter expansion
  local no_leading="${input#"${input%%[![:space:]]*}"}"
  local no_trailing="${no_leading%"${no_leading##*[![:space:]]}"}"

  echo "$no_trailing"
}
