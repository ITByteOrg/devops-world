#!/usr/bin/env bash
# --------------------------------------------------------------------
# File: shared-utils.sh
#
# Description:
#   Reusable Bash utility functions for console messaging and logging.
#   Designed for use in Git hooks and CI workflows.
#   Mirrors SharedUtils.psm1 for cross-platform visual consistency.
#
# Functions:
#   write_stdlog <message> <type>
#     - Outputs colored message to stdout based on log type.
#     - Supports: info, warn, error, success, raw, [blank]
#
#   write_log <message> <type> [logDir]
#     - Outputs colored message to stdout.
#     - If logDir is provided, appends timestamped entry to file.
#
# Dependencies:
#   None externally. Assumes script is sourced via:
#     GIT_ROOT="$(git rev-parse --show-toplevel)"
#     source "$GIT_ROOT/scripts/modules/shared-utils.sh"
# --------------------------------------------------------------------

set -euo pipefail  # Exit on error, treat unset vars as errors, fail on pipe errors

# Prefix map for structured log types
declare -A PREFIX_MAP=(
  [info]="[INFO]"
  [warn]="[WARN]"
  [error]="[ERROR]"
  [success]="[SUCCESS]"
  [ok]="[OK]"
  [debug]="[DEBUG]"
)

# ANSI color map for structured log types
declare -A COLOR_MAP=(
  [info]="\033[36m"
  [warn]="\033[33m"
  [error]="\033[31m"
  [success]="\033[32m"
  [ok]="\033[32m"
  [debug]="\033[90m"
  [default]="\033[37m"
)

COLOR_RESET="\033[0m"

write_log() {
  # ── Full log function with optional file write
  local raw_type="${1:-info}" # Default to 'info' if no type provided
  local type="${raw_type,,}"  # Normalize type to lowercase
  local message="$2"
  local log_dir="${3:-}"      # optional: log directory
  local log_name="${4:-}"     # optional: log file name

  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  local color="${COLOR_MAP[$type]:-${COLOR_MAP[default]}}"
  local prefix="${PREFIX_MAP[$type]:-$raw_type}" 
  
  # ── Console output
  echo -e "${color}${prefix} ${message}${COLOR_RESET}"

  # ── Optional log file write
  if [[ -n "$log_dir" ]]; then
    mkdir -p "$log_dir"
    local script_name="$(basename "${BASH_SOURCE[1]}")"
    local log_file="${log_dir}/${log_name:-${script_name%.sh}.log}"
    local clean_message="$(echo "$message" | sed -r 's/\x1B\[[0-9;]*[mK]//g')"

    echo "[$timestamp][$type] $clean_message" >> "$log_file"
  fi
}

write_stdlog() {
  # ── Wrapper for write_log without file output
  local message="$1"
  local raw_type="${2:-info}" # Default to 'info' if no type provided

  write_log "$raw_type" "$message"
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
