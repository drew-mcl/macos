# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS laptop setup repository using GNU Stow for dotfile management and Make for orchestration. It provisions development tools via Homebrew, manages language runtimes via mise, and symlinks dotfiles to `$HOME`. Visual theme is Catppuccin Macchiato across all tools.

## Common Commands

```bash
make bootstrap        # Full setup: git, ssh, brew, github, stow, oh-my-zsh, mise, macos
make stow             # Restow all dotfiles after changes
make stow-clean       # Backup conflicts to ~/.local/share/macos/backups/, then restow
make doctor           # Print diagnostics for installed tools
make brew             # Install all Homebrew packages (base + apps)
make mise-install     # Install language runtimes from mise config
make setup-git        # Configure git identity and defaults
make setup-ssh        # Generate SSH key and configure agent
make install-brew     # Install Homebrew if not present
make macos            # Apply macOS defaults
make unstow           # Remove all symlinks
make nuke             # Full reset: unstow, remove oh-my-zsh, re-bootstrap
make help             # Show all available targets (default)
```

## The `ws` Command

A shell function for managing workstation config:

```bash
ws brew      # Edit Brewfiles
ws zsh       # Edit .zshrc
ws git       # Edit .gitconfig
ws ghostty   # Edit Ghostty config
ws nvim      # Edit Neovim config
ws mise      # Edit mise runtime versions
ws star      # Edit Starship prompt
ws ssh       # Edit SSH config
ws claude    # Edit global CLAUDE.md
ws edit      # FZF picker for any config file
ws sync      # Commit + push changes
ws stow      # Re-stow all packages
ws doctor    # Run diagnostics + drift check
ws update    # Brew update + restow
ws profile   # Shell startup time profiling
```

## Architecture

### Dotfiles Structure

Each folder in `dotfiles/` is a GNU Stow package. Running `stow <package>` symlinks its contents to `$HOME`. The `--no-folding` flag ensures individual files are symlinked rather than entire directories.

Current stow packages: `curl git glab ghostty mise ruby ssh zsh direnv starship yazi atuin nvim claude lazygit`

### Global Claude Code Config

The `claude` stow package installs `~/.claude/CLAUDE.md` with global dev workflows (Rails conventions, git workflow, testing patterns). This applies to all repos unless overridden by a project-level CLAUDE.md.

### Brewfiles

- `brew/Brewfile.base` - Core CLI tools (stow, mise, starship, fzf, ripgrep, etc.)
- `brew/Brewfile.apps` - GUI applications (Ghostty, Obsidian, draw.io, fonts)

### Scripts

Helper scripts in `scripts/` are invoked by Make targets:
- `bootstrap-prebrew.sh` - Configure git/curl before Homebrew is available
- `ssh-setup.sh` - Generate ed25519 key and add to agent
- `ssh-host.sh` - Generate per-host SSH keys with config.d entries
- `macos-defaults.sh` - Apply macOS system preferences
- `dirs.sh` - Create ~/repos, ~/repos/worktrees, ~/.local/bin

### Shell Configuration

The main shell config is `dotfiles/zsh/.zshrc` which:
1. Initializes Homebrew
2. Sets Catppuccin Macchiato theme (BAT_THEME, FZF_DEFAULT_OPTS)
3. Loads oh-my-zsh with plugins (git, fzf)
4. Activates mise, direnv, zoxide, atuin
5. Sets up Starship prompt
6. Defines aliases, helpers, `ws` command, and `obsidian-sync`

### Theme: Catppuccin Macchiato

Applied consistently across: Ghostty, Neovim, bat, fzf, git-delta, lazygit, Starship, Yazi.

## Conventions

- Commits follow conventional commits: `feat(scope):`, `fix(scope):`, `refactor(scope):`
- Scripts should be idempotent - safe to re-run
- Custom per-machine scripts go in `custom/` and run via `make custom`
- Stow package additions require updating `STOW_PACKAGES` in the Makefile
- Always edit source files in this repo, never the symlinked targets
