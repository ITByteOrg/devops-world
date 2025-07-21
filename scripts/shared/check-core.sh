#!/usr/bin/env bash
# check-core.sh — Shared step execution utilities

run_step() {

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "$SCRIPT_DIR/../modules/shared-utils.sh"
  
  local label="$1"
  local cmd="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  local action_list="$5"  # e.g., ACTIONS or FIX_ACTIONS
  local quiet="$6"

  echo-StdLog ""
  echo-StdLog "${label}:" raw

  [[ "$quiet" == "true" ]] && cmd="$cmd -q"

  local output status
  output=$(eval "$cmd" 2>&1)
  status=$?

  [[ -n "$output" ]] && echo "$output"

  if [[ $status -eq 0 ]]; then
    echo-StdLog "[OK] $ok_msg" success
    eval "$action_list+=(\"[OK] $label\")"
  else
    echo-StdLog  "[ERROR] $fail_msg"
    eval "$action_list+=(\"[X] $label\")"
    STATUS="[ERROR] One or more steps failed"
    EXIT_CODE=1
  fi
}

# run_check()
# Simplified wrapper for validation steps.
# Internally delegates to run_step() with "ACTIONS" as the target summary array.
#
# Args:
#   $1 - Label (e.g., "BANDIT")
#   $2 - Command to execute (e.g., "bandit -r src")
#   $3 - Message shown when successful
#   $4 - Message shown when failed
#   $5 - Optional: "true" if command supports quiet mode (-q)
#
# This hardcodes "ACTIONS" as the fifth parameter to run_step.
# In bin/check, you only pass 4–5 arguments; this function wires it correctly.
run_check() {
  run_step "$1" "$2" "$3" "$4" "ACTIONS" "$5"
}

