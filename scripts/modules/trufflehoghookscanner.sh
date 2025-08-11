#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : trufflehoghookscanner.sh
# Purpose: Run TruffleHog against staged or pushed files
# Usage  : bash trufflehoghookscanner.sh <scanMode> <type>
# Notes  : Designed for Git hook integration; uses shared utils
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

scan_with_trufflehog() {

  # Run TruffleHog scan on specified files  
  local scanMode="${1:-staged}" # Default to 'staged' if not provided
  local type="${2:-info}"        # Default to 'info' if not provided
  type="${type,,}"               # Normalize type to lowercase

  write_stdlog "🔍 Running TruffleHog scan in '$scanMode' mode..." "$type"

    # config 
    local repoRoot="$(git rev-parse --show-toplevel)"
    local excludeFile="$repoRoot/.trufflehog-exclude.txt"
    local truffleCmd="$(command -v trufflehog)"
    [[ -z "$truffleCmd" ]] && log_error "TruffleHog CLI not found. Did you run trufflehog-install.sh?" && exit 1

    # Targets 
    local scanTargets=()
    if [[ "$scanMode" == "staged" ]]; then
        while IFS= read -r file; do
            [[ -f "$file" ]] && scanTargets+=("$file")
        done < <(git diff --cached --name-only)
    elif [[ "$scanMode" == "pushed" ]]; then
        while IFS= read -r file; do
            [[ -f "$file" ]] && scanTargets+=("$file")
        done < <(git diff HEAD~1 --name-only)
    else
        write-log "Unrecognized scan mode: $scanMode" error
        exit 1
    fi

    # Run TruffleHog Scan 
    if [[ "${#scanTargets[@]}" -eq 0 ]]; then
        write-log "No files to scan with TruffleHog." info
        exit 0
    fi

    write-log "Running TruffleHog scan on ${#scanTargets[@]} file(s)..." info
    for file in "${scanTargets[@]}"; do
        write-log "Scanning: $file" info
        "$truffleCmd" filesystem "$file" --exclude "$excludeFile" || {
            write-log "Potential secrets found in $file" warn
        }
    done

    write-log "TruffleHog hook scan completed." success
}

scan_with_trufflehog "$@"