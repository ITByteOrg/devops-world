#!/usr/bin/env bash
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
set -euo pipefail

VERSION="3.89.2"
TARBALL="trufflehog_${VERSION}_linux_amd64.tar.gz"
DOWNLOAD_URL="https://github.com/trufflesecurity/trufflehog/releases/download/v${VERSION}/${TARBALL}"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="trufflehog"

echo "📥 Downloading TruffleHog ${VERSION} from GitHub..."
curl -sSL "$DOWNLOAD_URL" -o "$TARBALL"

echo "📦 Extracting $TARBALL..."
tar -xzf "$TARBALL"

if [[ ! -f "$BINARY_NAME" ]]; then
  echo "❌ Expected binary '$BINARY_NAME' not found after extraction."
  exit 1
fi

echo "🔒 Setting executable permissions..."
chmod +x "$BINARY_NAME"

echo "🚀 Installing to $INSTALL_DIR..."
sudo mv "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"

echo "🔍 Verifying installed binary..."
if file "$INSTALL_DIR/$BINARY_NAME" | grep -q 'ELF'; then
  echo "✅ TruffleHog installed successfully."
else
  echo "❌ Invalid binary format. Check download integrity."
  exit 1
fi

# Cleanup (optional)
rm -f "$TARBALL" LICENSE README.md
