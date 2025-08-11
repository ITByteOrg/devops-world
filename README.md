# DevOps World

Welcome to **DevOps World** — your toolkit for automation, environment setup, and developer experience. This repo is designed to be cross-platform, script-aware, and easy to onboard.

## Getting Started

To set up your environment:

- **Linux/macOS**:  
  Run [`setup.sh`](setup.sh) from the root directory.

- **Windows**:  
  Run [`setup.ps1`](setup.ps1) in PowerShell (preferably with execution policy set to `RemoteSigned`).

These scripts install dependencies, configure your shell, and prepare the repo for development.

## Documentation

All documentation lives in [`docs/`](docs/tooling.md), including:

- Tooling and linting standards
- Shell customization and prompt logic
- Git hooks and pre-commit setup
- Onboarding philosophy and script design

## Contributing

We welcome contributions! Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for coding standards, naming conventions, and helper patterns.

## Testing & Linting

Run `make test` to execute tests.  
Run `make lint` to apply formatting and static analysis.
