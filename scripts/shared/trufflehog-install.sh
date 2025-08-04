#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Script : trufflehog-install.sh
# Purpose: Download and install TruffleHog CLI (v3.89.2) for use
#          in Git hooks, CI pipelines, or local security scans
# Location: scripts/shared/
# Usage   : bash scripts/shared/trufflehog-install.sh
# Notes   : Verifies ELF binary format before installation.
#           Designed for Linux-based CI runners and local dev.
# ─────────────────────────────────────────────────────────────

# Exit on error, unset variables trigger failure, and pipe errors are caught
set -euo pipefail

# Resolve repository root
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

VERSION="3.89.2"
TARBALL="trufflehog_${VERSION}_linux_amd64.tar.gz"
DOWNLOAD_URL="https://github.com/trufflesecurity/trufflehog/releases/download/v${VERSION}/${TARBALL}"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="trufflehog"

write-stdlog "📥 Downloading TruffleHog ${VERSION} from GitHub..." info
curl -sSL "$DOWNLOAD_URL" -o "$TARBALL"

write-stdlog "📦 Extracting $TARBALL...", info
tar -xzf "$TARBALL"

if [[ ! -f "$BINARY_NAME" ]]; then
  write-stdlog "❌ Expected binary '$BINARY_NAME' not found after extraction." error
  exit 1
fi

write-stdlog "🔒 Setting executable permissions..." info
chmod +x "$BINARY_NAME"

write-stdlog "🚀 Installing to $INSTALL_DIR..." info
sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"

write-stdlog "🔍 Verifying installed binary..." info
if file "$INSTALL_DIR/$BINARY_NAME" | grep -q 'ELF'; then
  write-stdlog "✅ TruffleHog installed successfully." success
else
  write-stdlog "❌ Invalid binary format. Check download integrity." error
  exit 1
fi

# Cleanup (optional)
rm -f "$TARBALL" LICENSE README.md
