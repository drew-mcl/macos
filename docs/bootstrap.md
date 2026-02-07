# Bootstrap Guide

From a fresh macOS install to a fully-loaded development environment.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Admin access
- Internet connection

## Quick Start

```bash
# 1. Clone the repo (using HTTPS initially, before SSH is set up)
git clone https://github.com/drew-mcl/laptop-setup.git ~/repos/laptop-setup
cd ~/repos/laptop-setup

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
| 5 | `stow-clean` | Backs up conflicting dotfiles, then symlinks all packages |
| 6 | `stow` | Re-stows all dotfile packages to `$HOME` |
| 7 | `oh-my-zsh` | Installs oh-my-zsh framework |
| 8 | `mise-install` | Installs language runtimes (Ruby, Node, Python, Go, Rust) |

## Environment Variables

You can skip prompts by setting these before running bootstrap:

```bash
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your@email.com"
```

Or create a `.env` file in the repo root with these values.

## After Bootstrap

1. **Add SSH key to GitHub**: `gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"`
2. **Switch remote to SSH**: `git remote set-url origin git@github.com:drew-mcl/laptop-setup.git`
3. **Set up Obsidian**: Open Obsidian, create vault at `~/Documents/Obsidian`
4. **macOS preferences**: `make macos` (adjusts Dock, Finder, keyboard settings)

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

If `make stow` fails with conflicts, run `make stow-clean` which backs up conflicting files to `~/.local/share/laptop-setup/backups/` before restowing.

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
