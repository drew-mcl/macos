#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" != darwin* ]]; then
  echo "[macos-dock] Non-macOS detected; skipping."
  exit 0
fi

if ! command -v dockutil >/dev/null 2>&1; then
  cat <<'EOF'
[macos-dock] 'dockutil' not found. Install it via Homebrew (brew install dockutil)
or ensure the Makefile's brew targets have been run.
EOF
  exit 0
fi

APPS=(
  "/Applications/Ghostty.app"
  "/Applications/Obsidian.app"
)

echo "[macos-dock] Pinning apps to Dock..."

for app in "${APPS[@]}"; do
  if [[ ! -d "$app" ]]; then
    echo "[macos-dock] Skipping missing app: $app"
    continue
  fi

  dockutil --remove "$app" --no-restart >/dev/null 2>&1 || true
  dockutil --add "$app" --no-restart
done

killall Dock >/dev/null 2>&1 || true

echo "[macos-dock] Dock updated."
