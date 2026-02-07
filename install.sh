#!/usr/bin/env bash
set -euo pipefail

# --- Colors ------------------------------------------------------------------
BOLD='\033[1m'
DIM='\033[2m'
BLUE='\033[38;5;117m'
GREEN='\033[38;5;114m'
PEACH='\033[38;5;209m'
MAUVE='\033[38;5;141m'
RED='\033[38;5;204m'
RESET='\033[0m'

REPO_URL="https://github.com/drew-mcl/macos.git"
REPO_DIR="$HOME/repos/macos"

# --- Helpers -----------------------------------------------------------------
step() { printf "\n${BLUE}${BOLD}==>${RESET} ${BOLD}%s${RESET}\n" "$1"; }
info() { printf "  ${DIM}%s${RESET}\n" "$1"; }
ok()   { printf "  ${GREEN}%s${RESET}\n" "$1"; }
warn() { printf "  ${PEACH}%s${RESET}\n" "$1"; }
err()  { printf "  ${RED}%s${RESET}\n" "$1"; }

# --- Banner ------------------------------------------------------------------
printf "\n"
printf "  ${MAUVE}${BOLD}macOS${RESET}\n"
printf "  ${DIM}a beautiful, opinionated dev workstation${RESET}\n"
printf "  ${DIM}made with ${RED}♥${RESET}\n"
printf "\n"

# --- Preflight ---------------------------------------------------------------
step "Checking prerequisites"

if [[ "$(uname)" != "Darwin" ]]; then
  err "This script is for macOS only."
  exit 1
fi
ok "macOS detected ($(sw_vers -productVersion))"

if ! command -v git >/dev/null 2>&1; then
  warn "git not found — installing Xcode Command Line Tools..."
  xcode-select --install 2>/dev/null || true
  until command -v git >/dev/null 2>&1; do sleep 5; done
fi
ok "git $(git --version | awk '{print $3}')"

# --- Clone -------------------------------------------------------------------
step "Setting up repository"

if [[ -d "$REPO_DIR/.git" ]]; then
  info "Already exists at $REPO_DIR"
  git -C "$REPO_DIR" pull --ff-only 2>/dev/null || true
  ok "Pulled latest"
else
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR" 2>&1 | while read -r line; do info "$line"; done
  ok "Cloned to $REPO_DIR"
fi

# --- Bootstrap ---------------------------------------------------------------
step "Running bootstrap"
info "This will take a while on a fresh install..."
printf "\n"

make -C "$REPO_DIR" bootstrap

# --- Done --------------------------------------------------------------------
printf "\n"
printf "  ${GREEN}${BOLD}Done!${RESET}\n"
printf "\n"
printf "  ${DIM}Open a new terminal to load your shell config.${RESET}\n"
printf "  ${DIM}Run ${RESET}${BOLD}ws help${RESET}${DIM} to manage your workstation.${RESET}\n"
printf "\n"
