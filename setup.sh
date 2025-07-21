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

COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;34m"
COLOR_WARN="\033[1;33m"
COLOR_ERROR="\033[1;31m"
COLOR_SUCCESS="\033[1;32m"

info()    { echo -e "${COLOR_INFO}[INFO] $1${COLOR_RESET}"; }
warn()    { echo -e "${COLOR_WARN}[WARN] $1${COLOR_RESET}"; }
error()   { echo -e "${COLOR_ERROR}[ERROR] $1${COLOR_RESET}"; }
success() { echo -e "${COLOR_SUCCESS}[OK] $1${COLOR_RESET}"; }

# --- Parse flags ---
FORCE=false
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  info "Force flag detected. Rebuilding virtual environment..."
fi

# --- Check Python ---
if ! command -v python3 >/dev/null; then
  error "Python3 not found. Please install Python 3.8+"
  exit 1
fi

# --- Check pip ---
if ! command -v pip3 >/dev/null; then
  error "pip3 not found. Please install pip for Python 3"
  exit 1
fi

# --- Create or rebuild virtualenv ---
if [[ -d ".venv" ]]; then
  if [[ "$FORCE" == "true" ]]; then
    info "Removing existing virtual environment..."
    rm -rf .venv
    python3 -m venv .venv
    success "Recreated virtual environment at .venv/"
  else
    success "Virtual environment already exists. Skipping creation."
  fi
else
  python3 -m venv .venv
  success "Created virtual environment at .venv/"
fi

# --- Activate environment ---
source .venv/bin/activate

# --- Install packages ---
info "Installing runtime dependencies from requirements.txt..."
pip install --upgrade pip
pip install -r requirements.txt

info "Installing development dependencies from requirements-dev.txt..."
pip install -r requirements-dev.txt

success "Python dependencies installed."

# --- Check for Docker ---
if ! command -v docker >/dev/null; then
  warn "Docker not found. TruffleHog scan and related workflows may not work."
else
  success "Docker is available."
fi

# --- Check for jq ---
if ! command -v jq >/dev/null; then
  info "jq not found. Attempting installation..."
  if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y jq
    success "jq installed via apt."
  else
    error "jq not available. Please install manually for summary parsing."
  fi
else
  success "jq is already installed."
fi

# --- Done ---
echo-StdLog 
success "Setup complete. To activate environment: source .venv/bin/activate"
