#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/drew-mcl/macos.git"
REPO_DIR="$HOME/repos/laptop-setup"

echo ""
echo "  macOS workstation setup"
echo "  made with <3"
echo ""

# Clone the repo
if [[ -d "$REPO_DIR/.git" ]]; then
  echo "[install] Repo already exists at $REPO_DIR, pulling latest..."
  git -C "$REPO_DIR" pull --ff-only
else
  echo "[install] Cloning to $REPO_DIR..."
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Run bootstrap
echo "[install] Running bootstrap..."
make -C "$REPO_DIR" bootstrap

echo ""
echo "  Done! Open a new terminal to load your shell config."
echo ""
