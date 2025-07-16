# Tooling Overview

This document outlines how command-line scripts and shared utilities are structured and interact in the `devops-world` repository. It is intended to guide contributors and maintainers in understanding script responsibilities, validation pipelines, and CI integration.

---

## Script Architecture

```
[ bin/check ] ──┬──▶ [ bin/lint ]
                ├──▶ [ flake8 / bandit / pytest ]
                ├──▶ [ .pre-commit-config.yaml inspection ]
                └──▶ [ scripts/shared/log-summary.sh ]
```

- `bin/fix` and `bin/lint` are standalone scripts intended for manual formatting and validation.
- `bin/check` serves as the unified validation pipeline and orchestrates all major checks.
- Each script sources `scripts/shared/bootstrap.sh` to configure the environment consistently.

---

## Environment Setup

All shell scripts rely on `bootstrap.sh`, which performs:

- `.env` loading (if present)
- Activation of the `.venv` virtual environment
- Setting of `PYTHONPATH=src` for local module resolution

This ensures cross-platform compatibility and consistent behavior in CI and developer machines.

---

## Logging Standards

Validation results are written to `/logs` using `log-summary.sh`, with the following structure:

- File name format: `{tool}-summary.md`
  - Example: `check-summary.md`
- Content includes:
  - Title
  - Status line
  - List of actions performed
  - Timestamp and metadata

This standardizes output for CI traceability, auditability, and contributor visibility.

---

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

---
