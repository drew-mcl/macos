# Bootstrap Guide

From a fresh macOS install to a fully-loaded development environment.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Admin access
- Internet connection

## Quick Start

```bash
# 1. Clone the repo (using HTTPS initially, before SSH is set up)
git clone https://github.com/drew-mcl/macos.git ~/repos/macos
cd ~/repos/macos

# 2. Run the full bootstrap
make bootstrap

# 3. Open a new terminal to load shell config

# 4. Apply macOS preferences (optional)
make macos
```

## What `make bootstrap` Does

The bootstrap runs these targets in order:

| Step | Target | What it does |
|------|--------|-------------|
| 1 | `setup-git` | Prompts for git user.name/email, sets sensible defaults |
| 2 | `setup-ssh` | Generates ed25519 key, adds to macOS keychain |
| 3 | `install-brew` | Installs Homebrew if not present |
| 4 | `brew` | Installs all formulae and casks from Brewfiles |
| 5 | `setup-github` | Authenticates with GitHub CLI and uploads SSH key |
| 6 | `stow-clean` | Backs up conflicting dotfiles, then symlinks all packages |
| 7 | `stow` | Re-stows all dotfile packages to `$HOME` |
| 8 | `oh-my-zsh` | Installs oh-my-zsh framework |
| 9 | `mise-install` | Installs language runtimes (Ruby, Node, Python, Go, Rust) |
| 10 | `macos` | Applies macOS defaults (Finder, Dock, keyboard) with confirmation |

## Environment Variables

You can skip prompts by setting these before running bootstrap:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"
```

Or create a `.env` file in the repo root with these values.

## After Bootstrap

1. **Switch remote to SSH**: `git remote set-url origin git@github.com:drew-mcl/macos.git`
2. **Set up Obsidian**: Open Obsidian, create vault at `~/Documents/Obsidian`

## Customization

### Adding a new tool

1. Add the formula to `brew/Brewfile.base` (CLI) or `brew/Brewfile.apps` (GUI)
2. Run `make brew`
3. If it needs config, create a stow package in `dotfiles/<name>/`
4. Add the package name to `STOW_PACKAGES` in the Makefile
5. Run `make stow`

### Per-machine scripts

Put machine-specific setup in `custom/` and run with `make custom`.

## Troubleshooting

### Stow conflicts

If `make stow` fails with conflicts, run `make stow-clean` which backs up conflicting files to `~/.local/share/macos/backups/` before restowing.

### Homebrew not found after install

Close and reopen your terminal, or run:
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### mise runtimes failing

Ensure build dependencies are installed:
```bash
brew install openssl@3 libyaml readline libffi
```
