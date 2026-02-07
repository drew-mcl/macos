SHELL := /bin/bash
.DEFAULT_GOAL := help

DOTFILES_DIR := $(CURDIR)/dotfiles
STOW_PACKAGES := curl git glab ghostty mise ruby ssh zsh direnv starship yazi atuin nvim claude lazygit

BREW := brew
BREW_DIR := $(CURDIR)/brew
BREWFILE_BASE := $(BREW_DIR)/Brewfile.base
BREWFILE_APPS := $(BREW_DIR)/Brewfile.apps

.PHONY: help bootstrap setup-git setup-ssh install-brew brew stow stow-clean unstow oh-my-zsh dirs ssh macos custom doctor mise-install refresh git-monorepo nuke

help: ## Show all available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

bootstrap: setup-git setup-ssh install-brew brew stow-clean stow oh-my-zsh mise-install ## Full setup from scratch
	@echo ""
	@echo "Bootstrap complete! Open a new terminal to load your shell config."
	@echo "Consider: make macos"

setup-git: ## Configure git identity and sensible defaults
	@echo "[setup-git] Configuring git..."
	@if [ -n "$${GIT_USER_NAME:-}" ]; then \
		git config --global user.name "$$GIT_USER_NAME"; \
	elif [ -z "$$(git config --global user.name)" ]; then \
		read -r -p "Git user.name: " name && git config --global user.name "$$name"; \
	fi
	@if [ -n "$${GIT_USER_EMAIL:-}" ]; then \
		git config --global user.email "$$GIT_USER_EMAIL"; \
	elif [ -z "$$(git config --global user.email)" ]; then \
		read -r -p "Git user.email: " email && git config --global user.email "$$email"; \
	fi
	@git config --global init.defaultBranch main
	@git config --global fetch.prune true
	@git config --global pull.ff only
	@git config --global rebase.autoStash true
	@git config --global merge.conflictstyle zdiff3
	@git config --global push.default simple
	@git config --global push.autoSetupRemote true
	@git config --global rerere.enabled true
	@git config --global credential.helper osxkeychain
	@echo "[setup-git] Done."

setup-ssh: ## Generate SSH key and add to keychain
	@echo "[setup-ssh] Checking SSH key..."
	@if [ ! -f "$$HOME/.ssh/id_ed25519" ]; then \
		email=$$(git config --global user.email); \
		if [ -z "$$email" ]; then read -r -p "Email for SSH key: " email; fi; \
		mkdir -p "$$HOME/.ssh" && chmod 700 "$$HOME/.ssh"; \
		ssh-keygen -t ed25519 -C "$$email" -f "$$HOME/.ssh/id_ed25519" -N ""; \
		if [[ "$$OSTYPE" == darwin* ]]; then \
			eval "$$(ssh-agent -s)" >/dev/null; \
			ssh-add --apple-use-keychain "$$HOME/.ssh/id_ed25519" 2>/dev/null || ssh-add "$$HOME/.ssh/id_ed25519"; \
		fi; \
		echo ""; \
		echo "Public key:"; \
		cat "$$HOME/.ssh/id_ed25519.pub"; \
		echo ""; \
		echo "Add to GitHub: gh ssh-key add ~/.ssh/id_ed25519.pub --title \"$$(hostname)\""; \
	else \
		echo "[setup-ssh] Key already exists: ~/.ssh/id_ed25519"; \
	fi
	@git config --global gpg.format ssh
	@git config --global user.signingkey "$$HOME/.ssh/id_ed25519.pub"
	@git config --global commit.gpgsign true

install-brew: ## Install Homebrew if not present
	@if ! command -v $(BREW) >/dev/null 2>&1; then \
		echo "[install-brew] Installing Homebrew..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do \
			if [ -x "$$brew_candidate" ]; then eval "$$($$brew_candidate shellenv)"; break; fi; \
		done; \
	else \
		echo "[install-brew] Homebrew already installed."; \
	fi

brew: ## Install all Homebrew packages
	@command -v $(BREW) >/dev/null 2>&1 || { echo "brew not found. Run 'make install-brew' first."; exit 1; }
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_BASE)
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_APPS) || true
	@if [ -d "$$($(BREW) --prefix)/opt/fzf" ]; then "$$($(BREW) --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish; fi

stow: ## Symlink all dotfiles to $HOME
	@command -v stow >/dev/null 2>&1 || { echo "stow not found. Run 'make brew' first."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Stowing %s...\n" $$pkg; \
		stow --no-folding --restow -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done
	@if command -v ya >/dev/null 2>&1 && ya pack --help >/dev/null 2>&1; then echo "Installing yazi flavors..."; ya pack -a yazi-rs/flavors:catppuccin-macchiato; fi

stow-clean: ## Backup conflicts then restow
	@command -v stow >/dev/null 2>&1 || { echo "stow not found. Run 'make brew' first."; exit 1; }
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

unstow: ## Remove symlinks for all stow packages
	@command -v stow >/dev/null 2>&1 || { echo "stow not found."; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "Unstowing %s...\n" $$pkg; \
		stow -D -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

oh-my-zsh: ## Install oh-my-zsh
	@bash ./scripts/install-oh-my-zsh.sh

dirs: ## Create dev directories
	@bash ./scripts/dirs.sh

ssh: ## Setup SSH key and agent
	@bash ./scripts/ssh-setup.sh

macos: ## Apply macOS defaults
	@bash ./scripts/macos-defaults.sh

custom: ## Run optional custom scripts
	@bash ./scripts/run-custom.sh

git-monorepo: ## Optimize a large monorepo (REPO=/path/to/repo)
	@bash ./scripts/git-monorepo.sh "$(REPO)"

refresh: ## Brew update + restow
	@command -v brew >/dev/null 2>&1 && brew update && brew upgrade || true
	@$(MAKE) stow

mise-install: ## Install language runtimes from mise config
	@command -v mise >/dev/null 2>&1 || { echo "mise not found. Run 'make brew' first."; exit 1; }
	@echo "Installing runtimes via mise..."
	@mise install

doctor: ## Print environment diagnostics
	@echo "Shell: $$SHELL" && echo
	@echo "Home: $$HOME" && echo
	@echo "brew: $$(command -v brew || echo missing)" && brew --version 2>/dev/null || true
	@echo && echo "git: $$(command -v git || echo missing)" && git --version 2>/dev/null || true
	@echo && echo "stow: $$(command -v stow || echo missing)" && stow --version 2>/dev/null || true
	@echo && echo "zsh: $$(command -v zsh || echo missing)" && zsh --version 2>/dev/null || true
	@echo && echo "mise: $$(command -v mise || echo missing)" && mise --version 2>/dev/null || true
	@echo && echo "node: $$(command -v node || echo missing)" && node --version 2>/dev/null || true
	@echo && echo "python: $$(command -v python3 || echo missing)" && python3 --version 2>/dev/null || true
	@echo && echo "ruby: $$(command -v ruby || echo missing)" && ruby --version 2>/dev/null || true
	@echo && echo "go: $$(command -v go || echo missing)" && go version 2>/dev/null || true
	@echo && echo "rust: $$(command -v rustc || echo missing)" && rustc --version 2>/dev/null || true
	@echo && echo "nvim: $$(command -v nvim || echo missing)" && nvim --version 2>/dev/null | head -1 || true
	@echo && echo "gh: $$(command -v gh || echo missing)" && gh --version 2>/dev/null | head -1 || true
	@echo && echo "glab: $$(command -v glab || echo missing)" && glab --version 2>/dev/null || true

nuke: ## Full reset: unstow, remove oh-my-zsh, re-bootstrap
	@echo "WARNING: This will unstow dotfiles, remove ~/.oh-my-zsh, and rerun the full bootstrap with stow-clean."; \
	read -r -p "Type 'yes' to continue: " answer; \
	[ "$$answer" = "yes" ] || { echo "Aborted."; exit 1; }
	@$(MAKE) unstow
	@rm -rf "$$HOME/.oh-my-zsh"
	@$(MAKE) bootstrap
	@echo "Nuke complete."
