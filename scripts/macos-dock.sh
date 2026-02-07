#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" != darwin* ]]; then
  echo "[macos-dock] Non-macOS detected; skipping."
  exit 0
fi

if ! command -v dockutil >/dev/null 2>&1; then
  echo "[macos-dock] 'dockutil' not found — install with: brew install dockutil"
  exit 0
fi

APPS=(
  "/System/Applications/Safari.app"
  "/System/Applications/Mail.app"
  "/System/Applications/System Settings.app"
  "/Applications/draw.io.app"
  "/Applications/Obsidian.app"
  "/Applications/Ghostty.app"
)

echo ""
echo "[macos-dock] This will:"
echo "  - Remove ALL current Dock items"
echo "  - Pin these apps (in order):"
for app in "${APPS[@]}"; do
  name=$(basename "$app" .app)
  echo "    • $name"
done
echo ""

read -r -p "[macos-dock] Continue? (y/n) " answer
if [[ "$answer" != [yY] ]]; then
  echo "[macos-dock] Skipped."
  exit 0
fi

echo "[macos-dock] Clearing Dock..."
dockutil --remove all --no-restart

echo "[macos-dock] Adding apps..."
for app in "${APPS[@]}"; do
  if [[ ! -d "$app" ]]; then
    echo "[macos-dock] Skipping missing app: $app"
    continue
  fi
  dockutil --add "$app" --no-restart
done

killall Dock >/dev/null 2>&1 || true

echo "[macos-dock] Done."
