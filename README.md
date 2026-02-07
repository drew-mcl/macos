# macOS

> a beautiful, opinionated dev workstation

From zero to a fully-loaded development environment in a single command.
Built to bootstrap. Designed to customize.

## Quick Start

```bash
git clone https://github.com/drew-mcl/laptop-setup.git ~/repos/laptop-setup
cd ~/repos/laptop-setup
make bootstrap
```

That's it. Open a new terminal and you're ready to go.

## What's Inside

**50+ CLI tools** via Homebrew - ripgrep, fzf, bat, eza, lazygit, yazi, zoxide, atuin, and more.

**5 language runtimes** via mise - Ruby 4, Node LTS, Python 3.14, Go 1.25, Rust stable.

**Catppuccin Macchiato** everywhere - Ghostty, Neovim, bat, fzf, git-delta, lazygit, Starship, Yazi.

**GNU Stow** dotfiles - 15 packages symlinked to `$HOME`, version-controlled and repeatable.

**One-command bootstrap** - git setup, SSH key generation, Homebrew, all packages, dotfiles, runtimes.

## The `ws` Command

Manage your workstation config from anywhere:

```bash
ws zsh       # Edit shell config
ws brew      # Edit Brewfiles
ws git       # Edit git config
ws nvim      # Edit Neovim config
ws edit      # FZF picker for any file
ws sync      # Commit + push changes
ws stow      # Re-symlink all dotfiles
ws doctor    # Check for drift
ws update    # Brew update + restow
ws profile   # Shell startup timing
```

Tab completion included. Run `ws help` for all commands.

## Make Targets

```
make help             # Show all targets (default)
make bootstrap        # Full setup from scratch
make brew             # Install Homebrew packages
make stow             # Symlink dotfiles
make doctor           # Environment diagnostics
make mise-install     # Install language runtimes
make macos            # Apply macOS preferences
make nuke             # Full reset + re-bootstrap
```

## Docs

Detailed documentation lives in [`docs/`](docs/README.md):

- [Bootstrap Guide](docs/bootstrap.md) - Step-by-step setup walkthrough
- [CLI Tools](docs/cli-tools.md) - Complete tool reference
- [Shell Reference](docs/shell.md) - Aliases, functions, environment
- [Catppuccin Theme](docs/catppuccin.md) - Theme configuration
- [LazyVim Cheatsheet](docs/lazyvim-cheatsheet.md) - Neovim keybindings

## Customization

**Add a Homebrew package**: Edit `brew/Brewfile.base` (CLI) or `brew/Brewfile.apps` (GUI), then `make brew`.

**Add a dotfile package**: Create `dotfiles/<name>/` with the home-relative path, add to `STOW_PACKAGES` in the Makefile, then `make stow`.

**Per-machine scripts**: Drop scripts in `custom/` and run `make custom`.

**Change the theme**: See [Catppuccin docs](docs/catppuccin.md) for switching flavors across all tools.
