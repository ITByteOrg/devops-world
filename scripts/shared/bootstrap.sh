#!/usr/bin/env bash


# Load environment variables
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️  Warning: .env file not found. Continuing without environment overrides."
fi

# Cross-platform .venv activation
if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
elif [ -f ".venv/Scripts/activate" ]; then
  source .venv/Scripts/activate
else
  echo "❌ ERROR: Could not activate .venv"
  exit 1
fi

# Detect Python executable
if [ -x ".venv/bin/python" ]; then
  export VENV_PY=".venv/bin/python"
elif [ -x ".venv/Scripts/python.exe" ]; then
  export VENV_PY=".venv/Scripts/python.exe"
else
  echo "❌ ERROR: Could not find .venv Python"
  exit 1
fi

# Set Python path
export PYTHONPATH=src
