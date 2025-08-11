#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# File: bootstrap.sh
# Purpose: Prepares the local environment for Bash-based workflows.
#
# Responsibilities:
#   - Loads environment variables from .env (if present)
#   - Activates the Python virtual environment (.venv)
#   - Detects the correct Python executable inside .venv
#   - Sets PYTHONPATH=src for module resolution
#
# This script ensures a consistent runtime state before running tools
# like linting, TruffleHog scans, or hook wrappers from Bash.
#
# Usage:
#   source scripts/shared/bootstrap.sh
# -----------------------------------------------------------------------------

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  write_stdlog "Warning: .env file not found. Continuing without environment overrides." warn
fi

# Cross-platform .venv activation
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
  source .venv/Scripts/activate
else
  write_stdlog "ERROR: Could not activate .venv" error
  exit 1
fi

# Detect Python executable
if [ -x ".venv/bin/python" ]; then
  export VENV_PY=".venv/bin/python"
elif [ -x ".venv/Scripts/python.exe" ]; then
  export VENV_PY=".venv/Scripts/python.exe"
else
  write_stdlog "ERROR: Could not find .venv Python" error
  exit 1
fi

# Set Python path
export PYTHONPATH=src
