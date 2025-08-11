# Tooling Overview

This document outlines how command-line scripts and shared utilities are structured and interact in the `devops-world` repository. It is intended to guide contributors and maintainers in understanding script responsibilities, validation pipelines, and CI integration.

## Script Architecture

```
[ bin/check ] ──┬──▶ [ bin/lint ]
                ├──▶ [ flake8 / bandit / pytest ]
                ├──▶ [ .pre-commit-config.yaml inspection ]
                └──▶ [ scripts/shared/log-summary.sh ]
```

Validation and formatting are driven by modular scripts:

- `bin/check`: Runs the full validation pipeline
- `bin/lint`: Applies formatting checks
- `bin/fix`: Auto-remediates lint violations
- `flake8`, `bandit`, `pytest`: Core tools for Python quality and security
- Each script sources `scripts/shared/bootstrap.sh` to configure the environment consistently.

## Environment Setup

All shell scripts rely on `bootstrap.sh`, which performs:

- `.env` loading (if present)
- Activation of the `.venv` virtual environment
- Setting of `PYTHONPATH=src` for local module resolution

Shared logic lives in `scripts/shared/bootstrap.sh` and is sourced by all contributor scripts.
This ensures cross-platform compatibility and consistent behavior in CI and developer machines.

## PowerShell Parity

To support Windows environments, setup.ps1 mirrors the behavior of setup.sh and follows the same onboarding philosophy:

- Loads .env variables if present
- Activates the local Python virtual environment
- Sets PYTHONPATH=src for module resolution
- Provides consistent logging and feedback

Where possible, PowerShell helpers replicate the logic of Bash utilities such as bootstrap.sh and log-summary.sh. This ensures contributors on Windows receive the same onboarding experience and validation feedback.

Scripts are designed to be modular and script-aware across platforms. Contributors extending functionality should consider wrapping shared logic in cross-shell helpers or documenting platform-specific behavior clearly.

## Logging Standards

Validation results are written to markdown logs in `/logs/` using `log-summary.sh`. Each log includes:

- Tool name and status
- Timestamp and metadata
- Actionable feedback

Logs follow the format `{tool}-summary.md` and are used in CI and PR reviews.

## Prompt Customization

Shell prompts are customized to improve developer awareness and reduce context-switching. Both Bash and PowerShell prompts include:

- Git branch detection
- Virtual environment indicators
- Exit code feedback (optional)
- Color-coded segments for readability

Prompt logic is modular and designed to be extensible. Bash customization is handled via bootstrap.sh, while PowerShell uses a matching prompt function defined in setup.ps1. ANSI codes are stripped or adjusted based on terminal capabilities to ensure clarity across platforms.

## CI Integration

The recommended CI entry point is:

```bash
make check
```

This triggers `bin/check` and performs:

- Style and lint verification (`bin/lint`)
- Static analysis with `flake8` and `bandit`
- Testing via `pytest`
- Configuration inspection of `.pre-commit-config.yaml`
- Summary log generation

Optional commands for contributors:

```bash
make fix     # Apply formatting and lint auto-remediation
make check   # Validate code, style, security, and tests
```

## Pre-commit Hooks

Pre-commit hooks enforce code quality before commits. Required hooks include:

- `black`, `isort`, `flake8`: Python formatting and linting
- `trufflehog-pwsh`: Secret scanning via Dockerized TruffleHog

Hooks are installed via:

```bash
source .venv/bin/activate  # macOS/WSL/Linux
# OR
.venv/Scripts/activate     # Windows

pip install pre-commit
pre-commit install
pre-commit autoupdate
```

## TruffleHog Integrations

This repository includes custom pre-commit hooks for secret scanning using TruffleHog v3 via Docker. Both PowerShell and Bash implementations are available to support cross-platform workflows.

| Hook Script                              | Language   | Location                                      | Install Command                        |
|------------------------------------------|------------|-----------------------------------------------|----------------------------------------|
| `trufflehog-pre-commit.ps1`              | PowerShell | `scripts/githooks/trufflehog-pre-commit.ps1`  | `pwsh scripts/bootstrap-hooks.ps1`     |
| `trufflehog-pre-commit.sh`               | Bash       | `scripts/githooks/trufflehog-pre-commit.sh`   | `bash scripts/bootstrap-hook.sh`       |

### Behavior

- Scans staged files for secrets using TruffleHog v3 via Docker
- Skips empty or deleted files for efficiency
- Logs results using shared modules:
  - PowerShell: `LoggingUtils.psm1`, `TruffleHogShared.psm1`
  - Bash: `logging-utils.sh`, `trufflehog-shared.sh`
- Verifies no CRLF line endings exist in `bin/` scripts
- Modularized for reuse across workflows

These hooks are referenced locally in `.pre-commit-config.yaml` for clarity and traceability, and live outside the Python pre-commit ecosystem.

## Shared Bootstrapping Scripts

These scripts initialize environment variables, activate virtual environments, and configure paths for consistent behavior across platforms.

| Script          | Language   | Purpose                                                                 |
|-----------------|------------|-------------------------------------------------------------------------|
| `bootstrap.ps1` | PowerShell | Loads `.env`, activates venv, sets `$env:Path`, used in Windows workflows |
| `bootstrap.sh`  | Bash       | Loads `.env`, activates venv, sets `$PATH`, used in macOS/Linux workflows |

Both scripts are sourced early in contributor workflows to ensure consistent setup across environments. They live in `scripts/shared/` and are referenced by validation, logging, and onboarding utilities.

### Usage

PowerShell:

```powershell
. scripts/shared/bootstrap.ps1
```

Bash:

```bash
source scripts/shared/bootstrap.sh
```

Both scripts:
- Detect and activate virtual environments
- Load environment variables from .env
- Update system paths for tool discovery
- Print progress messages for visibility
- Are modular and reusable across CI, local setup, and validation pipelines

## Contribution Guidelines

For more details, see [`CONTRIBUTING.md`](../CONTRIBUTING.md).