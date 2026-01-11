# Laptop Setup

Idempotent macOS laptop setup with GNU Stow dotfiles and Makefile orchestration.

## Quick Start

```bash
# 1. Install Homebrew first (via your internal tooling if applicable)

# 2. Full setup
make bootstrap

# 3. After changing dotfiles
make stow
```

## Make Targets

| Target | Description |
|--------|-------------|
| `bootstrap` | Full setup: brew, stow, oh-my-zsh, mise, vscode |
| `stow` | Restow all dotfiles to `$HOME` |
| `stow-clean` | Backup conflicts, then restow |
| `doctor` | Print environment diagnostics |
| `ssh` | Generate SSH key and configure agent |
| `macos` | Apply macOS defaults |
| `nuke` | Full reset and re-bootstrap |

## Stow Packages

Each folder in `dotfiles/` is a GNU Stow package symlinked to `$HOME`:

`atuin` `claude` `curl` `direnv` `ghostty` `git` `glab` `gradle` `mise` `nvim` `ruby` `ssh` `starship` `vscode` `yazi` `zsh`

## Brewfiles

- `brew/Brewfile.base` - Core CLI (stow, mise, fzf, ripgrep, starship)
- `brew/Brewfile.apps` - GUI apps (Ghostty, VS Code, Obsidian)
- `brew/Brewfile.langs` - Language toolchains (JDKs, terraform)

## Shell Helpers

| Command | Description |
|---------|-------------|
| `m` | Run make from nearest Makefile |
| `mt` | FZF make target picker |
| `y` | Yazi file manager with cd-on-exit |
| `z` | Zoxide smart cd |
| `sshx` | FZF SSH host picker |
| `repo` | Clone repos via gh/glab with FZF |
| `gpm` | Git prep-merge onto default branch |

## Git Aliases

```bash
gs    # git status -sb
gco   # git checkout
gb    # git branch -vv
gl    # git log --oneline --graph
gp    # git pull --ff-only && git push
gmr   # glab mr create --fill --remove-source-branch
```

## Language Runtimes

Managed by `mise`. Defaults in `dotfiles/mise/.config/mise/config.toml`.

## Customization

Put machine-specific scripts in `custom/` and run with `make custom`.
