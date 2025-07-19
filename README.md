# DevOps World

A modular DevOps toolkit for validating code quality, automating remediation, and enforcing documentation hygiene across cross-platform environments. Designed to support onboarding, repeatable workflows, and CI integration.

---

## Overview

This repository provides reusable scripts and validation tools for:

- Auto-remediating common formatting and lint errors
- Enforcing security and style checks across Python code
- Running consistent test suites
- Validating markdown documentation hygiene
- Activating shared pre-commit rules
- Centralizing environment setup and logging behaviors

---

## Repository Structure

```
├── bin/                       # Command-line scripts for fix, lint, and check
├── scripts/shared/           # Utilities for bootstrapping and summary logging
├── src/                      # Source code
├── tests/                    # Pytest-compatible test suite
├── setup.sh                  # Developer onboarding script
├── requirements.txt          # Runtime dependencies
├── requirements-dev.txt      # Development dependencies (flake8, pytest, etc.)
```

---

## Installation

To set up all required Python packages and system tools:

```bash
./setup.sh
```

To rebuild the virtual environment and reinstall everything:

```bash
./setup.sh --force
```

This script activates `.venv`, installs runtime and development packages, and ensures required tools like Docker and `jq` are available.

---

## Tooling Scripts

| Script       | Description                                                 |
|--------------|-------------------------------------------------------------|
| `bin/fix`    | Formats code using `black`, sorts imports using `isort`, and runs `flake8` to verify cleanliness. |
| `bin/lint`   | Performs non-destructive checks using `isort --check-only`, `black --check`, and `flake8`. |
| `bin/check`  | Runs full validation including `lint`, `bandit`, `pytest`, and pre-commit config inspection. |
| `bootstrap.sh` | Loads environment variables, activates virtualenv cross-platform, and sets `PYTHONPATH`. |
| `log-summary.sh` | Writes structured markdown logs in `/logs` reflecting scan outcomes. |

---

## Validation Workflow

To run the complete validation suite, use:

```bash
make check
```

This is the **all-in-one entrypoint** for contributors and CI pipelines. It performs:

- Linting and formatting verification (`bin/lint`)
- Static analysis (`flake8`) and security scanning (`bandit`)
- Test execution via `pytest`
- Pre-commit configuration inspection
- Structured summary logging in `logs/check-summary.md`

No separate `validate` target is required. This command ensures the codebase meets all quality, security, and configuration standards before commit or deployment.

To apply auto-remediation before running checks:

```bash
# Recommended workflow before commit
make fix     # Apply formatting and cleanup
make check   # Run full validation suite
```
---
### Pre-commit Hooks

Code formatting, linting, and secret scanning are enforced via `pre-commit` hooks. These run automatically before each commit.

See [CONTRIBUTING.md](CONTRIBUTING.md#pre-commit-configuration) for full setup instructions and hook definitions.

---

## Dependencies

Ensure your system has:

- Python 3.8 or later
- Docker (for TruffleHog and future workflows)
- GNU Make (install via `sudo apt install make`)
- PowerShell Core (required for `.ps1` scripts)
- `jq` (automatically installed via `setup.sh` on supported systems)

---

## Sample Output

A successful validation will produce a summary like the following in `logs/check-summary.md`:

```markdown
# Check Summary

Status: ✅ All checks passed

Actions Performed:
- lint passed
- flake8 passed
- bandit passed
- pytest passed
- pre-commit config valid

Metadata:
- Branch: feature
- Commit: abc1234
- Timestamp: 2025-07-14 21:22 EDT
```

This log can be used in CI or audits to confirm tooling results. 

---
