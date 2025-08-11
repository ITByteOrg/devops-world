# Contributing Guidelines

This document defines conventions for naming, scripting, logging, and workflow design in the `devops-world` repository. These standards help ensure clarity, modularity, and cross-platform consistency across contributions.

---

## Contribution Status

This repository is not currently accepting external contributions while core tooling and documentation are being refined. These guidelines are published in advance to support future collaboration and transparency.

This project is shared under the CC-BY-4.0 license and may be used or adapted freely. While pull requests are not accepted at this time, feedback and ideas are welcome via issues or mentions.

If you find the structure useful, feel free to adapt it for your own projects. Contributions may be welcomed in a future release.

---

## Getting Started

To configure your environment and install dependencies, see the [Installation section of README.md](./README.md#installation).

After setup, run the full validation pipeline:

```bash
make check
```

This command validates formatting, security, tests, markdown link integrity, and pre-commit configuration.

---

## Script Standards

All contributor scripts should follow these practices:

- Use `#!/usr/bin/env bash` for shell portability
- Include a header with purpose and usage
- Use `set -euo pipefail` to ensure safe execution
- Source shared environment setup:

  ```bash
  source scripts/shared/bootstrap.sh
  ```

- Print clear progress messages for each operation
- Exit with non-zero status on failure for CI visibility
- Write validation results to markdown logs using shared tooling

---

## Naming Conventions

### Scripts

- Actionable commands live in `bin/` and use lowercase names:

  | File       | Purpose                                  |
  |------------|-------------------------------------------|
  | `fix`      | Applies formatting and lint remediations  |
  | `lint`     | Checks formatting without modifying files |
  | `check`    | Runs full validation pipeline             |
  | `setup.sh` | Onboards developers with dependencies     |

- Reusable helpers live in `scripts/shared/`:

  | File              | Description                              |
  |-------------------|------------------------------------------|
  | `bootstrap.sh`     | Loads `.env`, activates venv, sets path  |
  | `log-summary.sh`   | Writes structured markdown summaries     |

### Logs

- Markdown summaries are written to `/logs/`
- Files must follow the format: `{tool}-summary.md`

  Example: `check-summary.md`

- Scripts must use `log-summary.sh` to generate logs with title, status, and actions

---

## Markdown Standards

Documentation follows the `.md` extension and consistent naming:

- `README.md`: Project overview and usage
- `CONTRIBUTING.md`: Contribution standards
- `TOC.md`: Dynamic table of contents
- Logs: `{purpose}-summary.md`

All documentation updates should preserve structure and readability. Badge placeholders and injected metadata should use clear identifiers when applicable.

---
### Pre-commit Configuration

This repository uses [`pre-commit`](https://pre-commit.com/) to enforce code quality checks before each commit. These hooks catch formatting issues, unsorted imports, lint violations, and potential secrets early — helping maintain code health across contributors.

#### Required Hooks

| Hook ID            | Description                                       | Source                          |
|--------------------|---------------------------------------------------|----------------------------------|
| `black`            | Formats Python files consistently                 | [`psf/black`](https://github.com/psf/black) |
| `isort`            | Sorts Python imports in canonical order           | [`mirrors-isort`](https://github.com/pre-commit/mirrors-isort) |
| `flake8`           | Detects style violations and unused code          | [`pycqa/flake8`](https://github.com/pycqa/flake8) |
| `trufflehog-pwsh`  | Scans staged files for secrets using Dockerized TruffleHog via PowerShell | Local hook: `scripts/githooks/trufflehog-pre-commit.ps1` |

#### Installation Steps

1. Activate the repo's virtual environment:
   ```bash
   source .venv/bin/activate        # macOS/WSL/Linux
   # OR
   .venv/Scripts/activate           # Windows
   ```

2. Install the framework and register hooks:
   ```bash
   pip install pre-commit
   pre-commit install
   pre-commit autoupdate
   ```

Hooks will now execute automatically when staging or committing files.

#### TruffleHog Integration Details

The custom hook `trufflehog-pwsh` is defined locally and installed via:

```bash
pwsh scripts/bootstrap-hooks.ps1
```

It performs the following checks before commits:

- Scans added or modified files for secrets using `TruffleHog v3` via Docker
- Skips empty or deleted files for efficiency
- Logs results using shared modules (`LoggingUtils.psm1`, `TruffleHogShared.psm1`)
- Verifies no CRLF line endings exist in any `bin/` scripts

All logic is modularized for reuse via shared components (LoggingUtils.psm1, TruffleHogShared.psm1), located in the shared module directory and used across multiple workflows.

This hook lives outside the Python `pre-commit` ecosystem but is referenced via `local` in `.pre-commit-config.yaml` for clarity and traceability.

---

## Submitting Changes

- Use descriptive feature branches: `feature/lint-enhancement`, `fix/docs-linkscan`
- All changes must pass `make check` locally
- Include summary logs from `/logs` as part of PR review
- Document new scripts or validations clearly

---

## License

This project is licensed under the terms outlined in `LICENSE.md`. All contributions will be attributed via pull request history.

