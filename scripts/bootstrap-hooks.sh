#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : bootstrap-hooks.sh
# Purpose: Load and execute Bash-based Git hook scripts
#          for modular DevSecOps workflows
# Location: scripts/shared/
# Usage   : bash scripts/shared/bootstrap-hooks.sh
# Notes   : Assumes hook scripts are named consistently and
#           located in scripts/hooks/
# ─────────────────────────────────────────────────────────────

# Ensure the script exits on error and treats unset variables as errors
set -euo pipefail

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

HOOK_SRC_DIR="$GIT_ROOT/scripts/hooks"
GIT_HOOK_DIR="$GIT_ROOT/.git/hooks"

HOOKS=("pre-commit.sh" "pre-push.sh" "post-checkout.sh")

for hook in "${HOOKS[@]}"; do
    src_path="$HOOK_SRC_DIR/$hook"
    tgt_path="$GIT_HOOK_DIR/${hook%.sh}"  # Strip .sh extension for Git compatibility

    if [[ -f "$src_path" ]]; then
        cp "$src_path" "$tgt_path"
        chmod +x "$tgt_path"
        write-stdlog "Installed $hook as ${tgt_path}" success
    else
        write-stdlog "Hook source not found: $src_path" warning
    fi
done

write-stdlog "All available hooks loaded." success
