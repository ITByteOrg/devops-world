#!/bin/bash
# --------------------------------------------------------------------
# File: setup.sh
# Purpose: Onboard developers with required Python and system-level tools.
#          - Creates or rebuilds Python virtual environment (.venv/)
#          - Installs runtime and development packages
#          - Validates system dependencies: jq and Docker
#
# Usage:
#   ./setup.sh           # Normal setup (skips .venv if it exists)
#   ./setup.sh --force   # Rebuild .venv and reinstall everything
# --------------------------------------------------------------------

set -euo pipefail

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

# --- Parse flags ---
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  write-stdlog "Force flag detected. Rebuilding virtual environment..." info
fi

# --- Check Python ---
if ! command -v python3 >/dev/null; then
  write-stdlog "Python3 not found. Please install Python 3.8+" error
  exit 1
fi

# --- Check pip ---
if ! command -v pip3 >/dev/null; then
  write-stdlog "pip3 not found. Please install pip for Python 3" error
  exit 1
fi

# --- Create or rebuild virtualenv ---
if [[ -d ".venv" ]]; then
  if [[ "$FORCE" == "true" ]]; then
    info "Removing existing virtual environment..."
    rm -rf .venv
    python3 -m venv .venv
    write-stdlog "Recreated virtual environment at .venv/" success
  else
    write-stdlog "Virtual environment already exists. Skipping creation." success
  fi
else
  python3 -m venv .venv
  write-stdlog "Created virtual environment at .venv/" success
fi

# --- Activate environment ---
source .venv/bin/activate

# --- Install packages ---
write-stdlog "Installing runtime dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

write-stdlog "Installing development dependencies from requirements-dev.txt..."
pip install -r requirements-dev.txt

write-stdlog "Python dependencies installed." success

# --- Check for Docker ---
if ! command -v docker >/dev/null; then
  write-stdlog "Docker not found. TruffleHog scan and related workflows may not work." warn
else
  write-stdlog "Docker is available." success
fi

# --- Check for jq ---
if ! command -v jq >/dev/null; then
  write-stdlog "jq not found. Attempting installation..." info
  if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y jq
    write-stdlog "jq installed via apt." success
  else
    write-stdlog "jq not available. Please install manually for summary parsing." error
  fi
else
  write-stdlog "jq is already installed." success
fi

# --- Done ---
write-stdlog "Setup complete. To activate environment: source .venv/bin/activate" success
