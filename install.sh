#!/usr/bin/env bash
# install.sh — Installer for acpi-detect-toggle

set -e

INSTALL_PATH="/usr/local/bin/toggle-ac-detect.sh"

echo "[INFO] Installing toggle-ac-detect.sh..."
sudo cp toggle-ac-detect.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"
echo "[DONE] Installed to $INSTALL_PATH"

echo
echo "Run commands:"
echo "  sudo toggle-ac-detect.sh --disable"
echo "  sudo toggle-ac-detect.sh --enable"
echo "  toggle-ac-detect.sh --status"

