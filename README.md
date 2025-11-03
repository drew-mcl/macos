# Laptop Setup & Dotfiles (Nix-first)

This repo now centers on a reproducible macOS setup powered by **nix-darwin** and **home-manager**. The previous GNU Stow + Makefile workflow still ships in the tree for reference, but the default path is declarative and flake-driven.

## Quick Start
1. **Install Nix (multi-user)**  
   Follow the [Determinate Systems installer](https://zero-to-nix.com/start/install/macos) or your preferred method. Reboot after the installer if prompted.
2. **Clone this repo**  
   ```bash
   git clone git@github.com:drew/laptop-setup.git
   cd laptop-setup
   ```
3. **Switch the full system (recommended)**  
   ```bash
   nix run nix-darwin -- switch --flake .#drew-mbp
   # …or after the first run:
   darwin-rebuild switch --flake .#drew-mbp
   ```
   This applies macOS defaults, installs Homebrew casks through `nix-homebrew`, and wires in the user profile.
4. **Only manage the user profile**  
   ```bash
   home-manager switch --flake .#drew@darwin
   ```
   Handy for experimenting without touching system-wide services.

> **Customize before running:**  
> - Update the host key (`darwinConfigurations."<hostname>"`) in `flake.nix` if you’re not on `drew-mbp`.  
> - Adjust `home.username`/`home.homeDirectory` inside `nix/home/drew.nix` for other accounts.  
> - Swap `system = "aarch64-darwin"` to `"x86_64-darwin"` on Intel Macs.

## Directory Layout
- `flake.nix` – entry point that wires nixpkgs, nix-darwin, home-manager, and nix-homebrew.  
- `nix/darwin/default.nix` – system-level tweaks: macOS defaults, fonts, nix settings, Homebrew casks.  
- `nix/home/drew.nix` – home-manager module that replaces GNU Stow by symlinking dotfiles, installing CLI tooling, and recreating helper scripts.  
- `dotfiles/` – canonical sources for configs (curl, git, ghostty, mise, ruby, ssh, starship, vscode, zsh, etc.).  
- `brew/`, `scripts/`, `Makefile` – legacy workflow retained for posterity; nothing depends on them in the Nix path.

## What the Flake Provides
- **Packages (user scope)** – git, git-cliff, delta, jq, ripgrep, fd, fzf, direnv, mise, starship, lazygit, terraform, consul, kubectl, helm, ansible, pipx, commitizen, gitlint, watchman, wget, coreutils, openssl, libffi, libyaml, pkg-config, readline, and more.  
- **Dotfiles** – home-manager links every file once managed by Stow (`~/.gitconfig`, `~/.zshrc`, `~/.curlrc`, `~/.config/mise/config.toml`, Ghostty config, VS Code settings, etc.). Executable helpers under `~/.local/bin/` are flagged correctly.  
- **macOS Defaults** – Finder tweaks, Dock autohide behaviour + pinned apps, key repeat rates, hidden `~/Library` toggle, and “save to disk” preference.  
- **Fonts** – Nerd Fonts (JetBrains Mono, Fira Code, Symbols-only) installed from `pkgs.nerdfonts`.  
- **Homebrew Casks** – Ghostty, Obsidian, IntelliJ IDEA, Visual Studio Code, draw.io managed declaratively via `nix-homebrew`.
- **Activation Hooks** – recreates `~/repos/{personal,work,archive}` plus `~/.local/bin`, `~/bin`, and `~/tmp` on every switch so scripts and FZF helpers continue to work.

## VS Code
- Settings are linked from `dotfiles/vscode/…/settings.json`.  
- The curated extension list lives in `vscode/extensions.txt`. Automating marketplace installs under Nix requires hashing extensions; that work is still outstanding, so run `scripts/vscode-setup.sh` (legacy) or install them manually for now.

## SSH Keys & Secrets
The declarative setup intentionally avoids generating keys or touching the macOS keychain. Reuse `scripts/ssh-setup.sh` or follow your corporate process after the switch.

## Legacy Makefile
The previous `make bootstrap` flow is untouched. You can keep using it on hosts that aren’t ready for Nix, or mine it for ad-hoc scripts. Nothing in the new flake depends on those targets.

## Troubleshooting Tips
- `nix run nix-darwin -- switch --flake .#drew-mbp --show-trace` surfaces module errors when you rename hosts or paths.  
- Homebrew casks still live under `/opt/homebrew` – `nix-homebrew` takes over Brewfile management, so `brew bundle` is no longer needed.  
- When editing dotfiles, re-run `home-manager switch --flake .#drew@darwin` to refresh symlinks.

## Next Ideas
- Port VS Code extensions into the flake via `pkgs.vscode-utils`.  
- Express SSH, macOS defaults, and other one-off scripts as dedicated modules.  
- Introduce host overlays for work/personal profiles once requirements diverge.
