SHELL := /bin/bash
.DEFAULT_GOAL := help

DOTFILES_DIR := $(CURDIR)/dotfiles
STOW_PACKAGES := curl git glab ghostty gradle mise ruby ssh vscode zsh direnv starship yazi atuin nvim

BREW := brew
BREW_DIR := $(CURDIR)/brew
BREWFILE_BASE := $(BREW_DIR)/Brewfile.base
BREWFILE_APPS := $(BREW_DIR)/Brewfile.apps
BREWFILE_LANGS := $(BREW_DIR)/Brewfile.langs
CODEX_PACKAGE ?= codex-cli
ifeq ($(strip $(CODEX_PACKAGE)),)
CODEX_PACKAGE := codex-cli
endif

PIPX_HOME ?= $(HOME)/.local/share/pipx
PIPX_BIN_DIR ?= $(HOME)/.local/bin
export PIPX_HOME
export PIPX_BIN_DIR

.PHONY: help bootstrap bootstrap-prebrew brew-core brew-dev brew-all install dotfiles refresh vscode git-monorepo stow stow-clean unstow oh-my-zsh dirs ssh macos custom doctor mise-install pipx-tools codex nuke

help:
	@echo "Targets:"
	@echo "  bootstrap          - Full setup: pre-brew config, brew bundle, mise install, dotfiles, shell, editor."
	@echo "  stow               - Restow all dotfiles into \\$$HOME after making changes."
	@echo ""
	@echo "Advanced:"
	@echo "  bootstrap-prebrew  - Configure git/curl before using brew; create dirs."
	@echo "  brew-core          - Install core CLI (stow, delta, jq, rg, etc.)."
	@echo "  brew-dev           - Install dev toolchain and apps (JDKs, terraform, etc.)."
	@echo "  brew-all           - Core + Dev."
	@echo "  oh-my-zsh          - Install oh-my-zsh (non-interactive)."
	@echo "  mise-install       - Install the default runtimes declared in mise config."
	@echo "  pipx-tools         - Install global pipx CLIs (commitizen, gitlint, etc.)."
	@echo "  stow-clean         - Backup conflicting files, then force a restow."
	@echo "  dirs               - Create dev directories (repos/...)."
	@echo "  ssh                - Setup SSH key and agent."
	@echo "  macos              - Apply macOS defaults (safe tweaks)."
	@echo "  custom             - Run optional custom scripts in custom/."
	@echo "  vscode             - Install VS Code extensions."
	@echo "  git-monorepo       - Optimize a large monorepo (REPO=/path/to/repo)."
	@echo "  refresh            - Update brew packages and restow."
	@echo "  unstow             - Remove symlinks for all stow packages."
	@echo "  nuke               - Remove existing symlinks and configs, then rerun bootstrap."
	@echo "  doctor             - Print environment diagnostics."

bootstrap: bootstrap-prebrew brew-all stow oh-my-zsh pipx-tools vscode codex mise-install
	@echo "Bootstrap complete. Consider: make ssh && make macos"

bootstrap-prebrew:
	@bash ./scripts/bootstrap-prebrew.sh

brew-core:
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew not found. Install via your internal tool."; exit 1; }
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_BASE)
	@# Post-install fzf key-bindings
	@if [ -d "$$($(BREW) --prefix)/opt/fzf" ]; then "$$($(BREW) --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc; fi

brew-dev:
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew not found. Install via your internal tool."; exit 1; }
	@echo "Using Oracle JDKs (via Brewfile.langs)"
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_LANGS) || true
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_APPS) || true

brew-all: brew-core brew-dev

install: brew-all stow oh-my-zsh pipx-tools vscode codex mise-install
	@echo "Install complete. Consider: make ssh && make macos"

dotfiles: stow

refresh:
	@command -v brew >/dev/null 2>&1 && brew update && brew upgrade || true
	@$(MAKE) stow

vscode:
	@bash ./scripts/vscode-setup.sh

git-monorepo:
	@bash ./scripts/git-monorepo.sh "$(REPO)"

stow:
	@command -v stow >/dev/null 2>&1 || { echo "stow not found. Run 'make brew-core' first."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Stowing %s...\n" $$pkg; \
		stow --no-folding --restow -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

stow-clean:
	@command -v stow >/dev/null 2>&1 || { echo "stow not found. Run 'make brew-core' first."; exit 1; }
	@backup_root="$$HOME/.local/share/laptop-setup/backups"; \
	timestamp="$$(date +%Y%m%d-%H%M%S)"; \
	backup_dir="$$backup_root/$$timestamp"; \
	mkdir -p "$$backup_dir"; \
	echo "Backing up conflicting files to $$backup_dir"; \
	for pkg in $(STOW_PACKAGES); do \
		printf "Stowing %s...\n" $$pkg; \
		while IFS= read -r -d '' rel; do \
			rel="$${rel#./}"; \
			[ -z "$$rel" ] && continue; \
			target="$$HOME/$$rel"; \
			if [ -L "$$target" ]; then \
				link_target=$$(readlink "$$target"); \
				case "$$link_target" in "$(DOTFILES_DIR)"/*) continue ;; esac; \
			fi; \
			if [ -e "$$target" ] || [ -L "$$target" ]; then \
				dest="$$backup_dir/$$rel"; \
				dest_dir=$$(dirname "$$dest"); \
				mkdir -p "$$dest_dir"; \
				mv "$$target" "$$dest"; \
				echo "  moved $$target -> $$dest"; \
			fi; \
		done < <(cd $(DOTFILES_DIR)/$$pkg && find . -mindepth 1 \( -type f -o -type l \) -print0); \
		stow --no-folding --restow -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

unstow:
	@command -v stow >/dev/null 2>&1 || { echo "stow not found."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Unstowing %s...\n" $$pkg; \
		stow -D -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

oh-my-zsh:
	@bash ./scripts/install-oh-my-zsh.sh

dirs:
	@bash ./scripts/dirs.sh

ssh:
	@bash ./scripts/ssh-setup.sh

macos:
	@bash ./scripts/macos-defaults.sh

custom:
	@bash ./scripts/run-custom.sh

nuke:
	@echo "WARNING: This will unstow dotfiles, remove ~/.oh-my-zsh, and rerun the full bootstrap with stow-clean."; \
	read -r -p "Type 'yes' to continue: " answer; \
	[ "$$answer" = "yes" ] || { echo "Aborted."; exit 1; }
	@$(MAKE) unstow
	@rm -rf "$$HOME/.oh-my-zsh"
	@$(MAKE) bootstrap-prebrew
	@$(MAKE) brew-all
	@$(MAKE) stow-clean
	@$(MAKE) oh-my-zsh
	@$(MAKE) vscode
	@$(MAKE) mise-install
	@echo "Nuke complete."

mise-install:
	@command -v mise >/dev/null 2>&1 || { echo "mise not found. Run 'make brew-core' first."; exit 1; }
	@echo "Installing runtimes via mise..."
	@mise install

codex:
	@command -v pipx >/dev/null 2>&1 || { echo "pipx not found. Run 'make brew-core' first or install via 'python3 -m pip install --user pipx'."; exit 1; }
	@mkdir -p "$(PIPX_HOME)" "$(PIPX_BIN_DIR)"
	@echo "[codex] Installing/Updating $(CODEX_PACKAGE) via pipx..."
	@pipx install $(CODEX_PACKAGE) --force
	@pipx ensurepath >/dev/null 2>&1 || true

pipx-tools:
	@command -v pipx >/dev/null 2>&1 || { echo "pipx not found. Run 'make brew-core' first."; exit 1; }
	@mkdir -p "$(PIPX_HOME)" "$(PIPX_BIN_DIR)"
	@echo "[pipx] Installing commitizen..."
	@pipx install commitizen --force
	@echo "[pipx] Installing gitlint..."
	@pipx install gitlint --include-deps --force

doctor:
	@echo "Shell: $$SHELL" && echo
	@echo "Home: $$HOME" && echo
	@echo "brew: $$(command -v brew || echo missing)" && brew --version 2>/dev/null || true
	@echo && echo "git: $$(command -v git || echo missing)" && git --version 2>/dev/null || true
	@echo && echo "stow: $$(command -v stow || echo missing)" && stow --version 2>/dev/null || true
	@echo && echo "zsh: $$(command -v zsh || echo missing)" && zsh --version 2>/dev/null || true
	@echo && echo "python: $$(command -v python3 || echo missing)" && python3 --version 2>/dev/null || true
	@echo && echo "go: $$(command -v go || echo missing)" && go version 2>/dev/null || true
	@echo && echo "glab: $$(command -v glab || echo missing)" && glab --version 2>/dev/null || true
	@echo && echo "nvim: $$(command -v nvim || echo missing)" && nvim --version 2>/dev/null | head -1 || true
	@echo && echo "yazi: $$(command -v yazi || echo missing)" && yazi --version 2>/dev/null || true
	@echo && echo "zoxide: $$(command -v zoxide || echo missing)" && zoxide --version 2>/dev/null || true
	@echo && echo "atuin: $$(command -v atuin || echo missing)" && atuin --version 2>/dev/null || true
	@echo && echo "JAVA: $$(/usr/libexec/java_home -V 2>/dev/null || echo none)" || true
