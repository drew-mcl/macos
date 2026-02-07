# Shell Reference

Complete reference for shell aliases, functions, and the `ws` command.

## The `ws` Command

Workstation config manager. Quick access to edit, sync, and diagnose your setup.

```bash
ws brew      # Edit Brewfiles
ws zsh       # Edit .zshrc
ws env       # Edit .zshenv
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

Tab completion is enabled for all `ws` subcommands.

## Git Aliases

| Alias | Expansion |
|-------|-----------|
| `gs` | `git status -sb` |
| `gco` | `git checkout` |
| `gb` | `git branch -vv` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gp` | `git pull --ff-only && git push` |
| `gpm` | `git prep-merge` (interactive rebase onto default branch) |
| `gpm1` | `git prep-merge-squash` (squash all commits to one) |

## GitLab Aliases

| Alias | Description |
|-------|-------------|
| `gmr` | Create MR with `--fill --remove-source-branch` |
| `gml` | List MRs assigned to me |
| `gms` | MR status |
| `gci` | View CI pipeline |
| `gmco` | FZF picker to checkout an open MR |

## Modern CLI Aliases

| Alias | Actual Command |
|-------|----------------|
| `cat` | `bat --paging=never` |
| `less` | `bat` |
| `du` | `dust` |
| `ps` | `procs` |
| `top` / `htop` | `btm --color gruvbox` |
| `vim` / `vi` | `nvim` |
| `ll` | `eza -lah --git --group-directories-first` |
| `clc` | `claude --dangerously-skip-permissions` |
| `be` | `bundle exec` |

## Shell Functions

| Function | Description |
|----------|-------------|
| `m [target]` | Run make from nearest parent Makefile |
| `mt` | FZF picker for make targets |
| `y` | Yazi file manager (cd on exit) |
| `z <dir>` | Zoxide smart cd (frecency-based) |
| `sshx` | FZF SSH host picker from config |
| `ssh-host <host>` | Generate per-host SSH key + config |
| `repo` | FZF browse + clone GitHub/GitLab repos into ~/repos |
| `aa` | FZF alias browser |
| `envim` | Open nearest .env file in nvim |
| `obsidian-sync` | Git commit + push Obsidian vault |

## Key Environment Variables

Set in `.zshenv`:

| Variable | Default | Description |
|----------|---------|-------------|
| `LAPTOP_SETUP` | `~/repos/laptop-setup` | Path to this repo |
| `OBSIDIAN_VAULT` | `~/Documents/Obsidian` | Path to Obsidian vault |
| `CLAUDE_CODE_ENABLE_TASKS` | `true` | Enable Claude Code task tracking |
| `BAT_THEME` | `Catppuccin Macchiato` | bat/cat syntax theme |
| `FZF_DEFAULT_OPTS` | (Catppuccin colors) | FZF appearance |

## Keychain Secrets

Secrets are managed via macOS Keychain helpers in `.zshenv`:

```bash
keychain-set VAR_NAME "value"   # Store a secret
keychain-get VAR_NAME           # Retrieve a secret
keychain-rm VAR_NAME            # Remove a secret
keychain-list                   # List all stored secrets
```

Secrets defined in `_KEYCHAIN_SECRETS` array are auto-loaded on shell start.
