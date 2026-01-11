# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS laptop setup repository using GNU Stow for dotfile management and Make for orchestration. It provisions development tools via Homebrew, manages language runtimes via mise, and symlinks dotfiles to `$HOME`.

## Common Commands

```bash
make bootstrap        # Full setup: pre-brew, brew bundles, stow, oh-my-zsh, mise, vscode
make stow             # Restow all dotfiles after changes
make stow-clean       # Backup conflicts to ~/.local/share/laptop-setup/backups/, then restow
make doctor           # Print diagnostics for installed tools
make brew-core        # Install base CLI tools (stow, delta, jq, rg, fzf)
make brew-dev         # Install dev apps (JDKs, terraform, GUI apps)
make mise-install     # Install language runtimes from mise config
make ssh              # Generate SSH key and configure agent
make macos            # Apply macOS defaults
make unstow           # Remove all symlinks
make nuke             # Full reset: unstow, remove oh-my-zsh, re-bootstrap
```

## Architecture

### Dotfiles Structure

Each folder in `dotfiles/` is a GNU Stow package. Running `stow <package>` symlinks its contents to `$HOME`. The `--no-folding` flag ensures individual files are symlinked rather than entire directories.

Current stow packages: `curl git glab ghostty gradle mise ruby ssh vscode zsh direnv starship yazi atuin nvim claude`

### Global Claude Code Config

The `claude` stow package installs `~/.claude/CLAUDE.md` with global dev workflows (Rails conventions, git workflow, testing patterns). This applies to all repos unless overridden by a project-level CLAUDE.md.

### Brewfiles

- `brew/Brewfile.base` - Core CLI tools (stow, mise, starship, fzf, ripgrep, etc.)
- `brew/Brewfile.apps` - GUI applications (Ghostty, VS Code, Obsidian, IntelliJ)
- `brew/Brewfile.langs` - Language toolchains (Oracle JDKs, terraform, consul)

### Scripts

Helper scripts in `scripts/` are invoked by Make targets:
- `bootstrap-prebrew.sh` - Configure git/curl before Homebrew is available
- `ssh-setup.sh` - Generate ed25519 key and add to agent
- `ssh-host.sh` - Generate per-host SSH keys with config.d entries
- `macos-defaults.sh` - Apply macOS system preferences
- `vscode-setup.sh` - Install VS Code CLI and extensions

### Shell Configuration

The main shell config is `dotfiles/zsh/.zshrc` which:
1. Initializes Homebrew
2. Loads oh-my-zsh with plugins (git, fzf)
3. Activates mise, direnv, zoxide, atuin
4. Sets up Starship prompt
5. Defines aliases and helper functions

Key shell functions: `m` (run make from nearest Makefile), `mt` (fzf make target picker), `sshx` (fzf SSH host picker), `repo` (clone repos via gh/glab), `y` (yazi with cd-on-exit)

## Conventions

- Commits follow conventional commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`
- Scripts should be idempotent - safe to re-run
- Custom per-machine scripts go in `custom/` and run via `make custom`
- Stow package additions require updating `STOW_PACKAGES` in the Makefile
