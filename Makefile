# --------------------------------------------------------------------
# Makefile for developer onboarding and tooling automation
# Wraps .github/bin scripts for consistency
# Available targets:
#   help      → Displays these descriptions
#   setup     → Runs ./setup.sh to install dependencies and tools
#   check     → Comprehensive validation pipeline (all-in-one)
#   dev       → Launches dev environment or services
#   fix       → Auto-remediates formatting and lint issues
#   lint      → Verifies formatting without modification
#   test      → Run unit tests with coverage
#   scan      → TruffleHog scan for secrets
#   clean     → Removes logs and local artifacts
#   lock      → stub - not working yet
#
# The check target runs all validations: lint, tests, security, and 
# config inspection. No separate validate target is required.
# --------------------------------------------------------------------

# Use bash as the shell for Makefile commands
SHELL := /bin/bash

.PHONY: setup check dev fix lint test scan clean lock
.PHONY: help

help: ## Show available Make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "} {printf "  %-15s %s\n", $$1, $$2}'

setup: ## Set up the development environment
	@./setup.sh

check:  ## Run all validation checks
	@bin/check

dev:  ## Launch dev environment or services
	@bin/dev

fix:  ## Auto-format and fix code issues
	@bin/fix

lint:  ## Run linting tools
	@bin/lint

test: ## Run unit tests with coverage
	@. scripts/shared/bootstrap.sh && \
	export PYTHONPATH=src && \
	.venv/bin/pytest tests --cov=src --cov-report=term > logs/coverage_summary.log
	@tail -n 10 logs/coverage_summary.log

scan:  ## Run TruffleHog wrapper for secret scanning
	@{ \
        source scripts/modules/shared-utils.sh; \
        if ! docker info > /dev/null 2>&1; then \
            echo-StdLog "Docker is not running. Please start the daemon before scanning." error; \
            exit 1; \
        fi; \
        ./scripts/shared/trufflehog-wrapper.sh --verbose --log logs/trufflehog_scan.json; \
    }

clean: ## Clean logs but preserve tracking file
	@find logs/ -type f ! -name '.keep' ! -name '.gitignore' -exec rm -f {} +

lock: ## Snapshot current environment
	@echo "[INFO:] Stub - will work on this later"
# 	@rm -rf .venv_lock && \
#     python -m venv .venv_lock && \
#     { \
#         source .venv_lock/bin/activate && \
#         pip install -r requirements.txt && \
#         pip freeze > requirements-prod.txt && \
#         deactivate; \
#     } && rm -rf .venv_lock

