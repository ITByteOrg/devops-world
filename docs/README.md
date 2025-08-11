# Documentation Overview

This folder contains extended documentation for the `devops-world` repository. It is intended to support onboarding, clarify tooling decisions, and explain the design of reusable scripts and helpers.

## Contents

- `tooling.md`: Development tools, linting standards, and shell customization
- `CONTRIBUTING.md`: Coding conventions, naming guidelines, and contribution process
- `setup.sh` and `setup.ps1`: Environment setup scripts for Linux/macOS and Windows
- `Makefile`: Entry points for testing, linting, and automation

## Onboarding Philosophy

Scripts and documentation are designed to be:

- Modular and maintainable
- Cross-platform compatible
- Easy to understand and extend
- Friendly to new contributors

Setup scripts are script-aware and include logging, color stripping, and environment detection. Prompts are customized to reflect Git status and virtual environments.

## Usage Notes

- Run setup scripts from the root directory
- Use `make lint` and `make test` to validate changes
- Refer to `tooling.md` for shell and editor configuration

## Contribution Guidelines

For more details, see [`CONTRIBUTING.md`](../CONTRIBUTING.md).
