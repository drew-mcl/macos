SHELL := /bin/bash
.DEFAULT_GOAL := help

DOTFILES_DIR := $(CURDIR)/dotfiles
STOW_PACKAGES := curl git glab ghostty mise ruby ssh zsh direnv starship yazi atuin nvim claude lazygit

BREW := brew
BREW_DIR := $(CURDIR)/brew
BREWFILE_BASE := $(BREW_DIR)/Brewfile.base
BREWFILE_APPS := $(BREW_DIR)/Brewfile.apps

# Colors (Catppuccin Macchiato palette)
BOLD := \033[1m
DIM := \033[2m
BLUE := \033[38;5;117m
GREEN := \033[38;5;114m
PEACH := \033[38;5;209m
MAUVE := \033[38;5;141m
RED := \033[38;5;204m
CYAN := \033[36m
RESET := \033[0m

# Brew optimization — skip auto-update during bootstrap
export HOMEBREW_NO_AUTO_UPDATE := 1
export HOMEBREW_NO_INSTALL_CLEANUP := 1
export HOMEBREW_NO_ANALYTICS := 1

.PHONY: help bootstrap setup-git setup-ssh install-brew brew stow stow-clean unstow oh-my-zsh dirs ssh macos custom doctor mise-install refresh git-monorepo nuke

help: ## Show all available targets
	@printf "\n  $(MAUVE)$(BOLD)macOS$(RESET) $(DIM)workstation targets$(RESET)\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-20s$(RESET) %s\n", $$1, $$2}'
	@printf "\n"

bootstrap: setup-git setup-ssh install-brew brew stow-clean stow oh-my-zsh mise-install ## Full setup from scratch
	@printf "\n"
	@printf "  $(GREEN)$(BOLD)Bootstrap complete!$(RESET)\n"
	@printf "\n"
	@printf "  $(DIM)Open a new terminal to load your shell config.$(RESET)\n"
	@printf "  $(DIM)Run $(RESET)$(BOLD)ws help$(RESET)$(DIM) to manage your workstation.$(RESET)\n"
	@printf "  $(DIM)Consider: $(RESET)$(BOLD)make macos$(RESET)\n"
	@printf "\n"

setup-git: ## Configure git identity and sensible defaults
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Configuring git$(RESET)\n"
	@if [ -n "$${GIT_USER_NAME:-}" ]; then \
		git config --global user.name "$$GIT_USER_NAME"; \
	elif [ -z "$$(git config --global user.name)" ]; then \
		read -r -p "    Git user.name: " name && git config --global user.name "$$name"; \
	fi
	@if [ -n "$${GIT_USER_EMAIL:-}" ]; then \
		git config --global user.email "$$GIT_USER_EMAIL"; \
	elif [ -z "$$(git config --global user.email)" ]; then \
		read -r -p "    Git user.email: " email && git config --global user.email "$$email"; \
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
	@printf "  $(GREEN)user.name  $(RESET)$$(git config --global user.name)\n"
	@printf "  $(GREEN)user.email $(RESET)$$(git config --global user.email)\n"

setup-ssh: ## Generate SSH key and add to keychain
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Setting up SSH$(RESET)\n"
	@if [ ! -f "$$HOME/.ssh/id_ed25519" ]; then \
		email=$$(git config --global user.email); \
		if [ -z "$$email" ]; then read -r -p "    Email for SSH key: " email; fi; \
		mkdir -p "$$HOME/.ssh" && chmod 700 "$$HOME/.ssh"; \
		ssh-keygen -t ed25519 -C "$$email" -f "$$HOME/.ssh/id_ed25519" -N ""; \
		if [[ "$$OSTYPE" == darwin* ]]; then \
			eval "$$(ssh-agent -s)" >/dev/null; \
			ssh-add --apple-use-keychain "$$HOME/.ssh/id_ed25519" 2>/dev/null || ssh-add "$$HOME/.ssh/id_ed25519"; \
		fi; \
		printf "  $(GREEN)Generated$(RESET) ~/.ssh/id_ed25519\n"; \
		printf "  $(DIM)Public key:$(RESET)\n"; \
		printf "  %s\n" "$$(cat $$HOME/.ssh/id_ed25519.pub)"; \
		printf "\n  $(DIM)Add to GitHub:$(RESET) gh ssh-key add ~/.ssh/id_ed25519.pub --title \"$$(hostname)\"\n"; \
	else \
		printf "  $(GREEN)Exists$(RESET) ~/.ssh/id_ed25519\n"; \
	fi
	@git config --global gpg.format ssh
	@git config --global user.signingkey "$$HOME/.ssh/id_ed25519.pub"
	@git config --global commit.gpgsign true

install-brew: ## Install Homebrew if not present
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Homebrew$(RESET)\n"
	@if ! command -v $(BREW) >/dev/null 2>&1; then \
		printf "  $(PEACH)Installing Homebrew...$(RESET)\n"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do \
			if [ -x "$$brew_candidate" ]; then eval "$$($$brew_candidate shellenv)"; break; fi; \
		done; \
		printf "  $(GREEN)Installed$(RESET)\n"; \
	else \
		printf "  $(GREEN)Already installed$(RESET) $$(brew --version 2>/dev/null | head -1)\n"; \
	fi

brew: ## Install all Homebrew packages
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Installing packages$(RESET)\n"
	@command -v $(BREW) >/dev/null 2>&1 || { printf "  $(RED)brew not found. Run 'make install-brew' first.$(RESET)\n"; exit 1; }
	@printf "  $(DIM)CLI tools...$(RESET)\n"
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_BASE)
	@printf "  $(DIM)GUI apps & fonts...$(RESET)\n"
	@$(BREW) bundle --no-upgrade --file=$(BREWFILE_APPS) || true
	@if [ -d "$$($(BREW) --prefix)/opt/fzf" ]; then \
		"$$($(BREW) --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish >/dev/null 2>&1; \
	fi
	@printf "  $(GREEN)All packages installed$(RESET)\n"

stow: ## Symlink all dotfiles to $HOME
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Stowing dotfiles$(RESET)\n"
	@command -v stow >/dev/null 2>&1 || { printf "  $(RED)stow not found. Run 'make brew' first.$(RESET)\n"; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "  $(DIM)%s$(RESET)\n" $$pkg; \
		stow --no-folding --restow -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done
	@if command -v ya >/dev/null 2>&1 && ya pack --help >/dev/null 2>&1; then \
		printf "  $(DIM)yazi flavors$(RESET)\n"; \
		ya pack -a yazi-rs/flavors:catppuccin-macchiato 2>/dev/null || true; \
	fi
	@printf "  $(GREEN)%s packages linked$(RESET)\n" "$$(echo $(STOW_PACKAGES) | wc -w | tr -d ' ')"

stow-clean: ## Backup conflicts then restow
	@command -v stow >/dev/null 2>&1 || { printf "  $(RED)stow not found. Run 'make brew' first.$(RESET)\n"; exit 1; }
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Resolving conflicts$(RESET)\n"
	@backup_root="$$HOME/.local/share/laptop-setup/backups"; \
	timestamp="$$(date +%Y%m%d-%H%M%S)"; \
	backup_dir="$$backup_root/$$timestamp"; \
	mkdir -p "$$backup_dir"; \
	for pkg in $(STOW_PACKAGES); do \
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
				printf "  $(PEACH)backed up$(RESET) $$rel\n"; \
			fi; \
		done < <(cd $(DOTFILES_DIR)/$$pkg && find . -mindepth 1 \( -type f -o -type l \) -print0); \
		stow --no-folding --restow -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done

unstow: ## Remove symlinks for all stow packages
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Removing symlinks$(RESET)\n"
	@command -v stow >/dev/null 2>&1 || { printf "  $(RED)stow not found.$(RESET)\n"; exit 1; }
	@for pkg in $(STOW_PACKAGES); do \
		printf "  $(DIM)%s$(RESET)\n" $$pkg; \
		stow -D -d $(DOTFILES_DIR) -t $$HOME $$pkg; \
	done
	@printf "  $(GREEN)All symlinks removed$(RESET)\n"

oh-my-zsh: ## Install oh-my-zsh
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Oh My Zsh$(RESET)\n"
	@bash ./scripts/install-oh-my-zsh.sh

dirs: ## Create dev directories
	@bash ./scripts/dirs.sh

ssh: ## Setup SSH key and agent
	@bash ./scripts/ssh-setup.sh

macos: ## Apply macOS defaults
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Applying macOS defaults$(RESET)\n"
	@bash ./scripts/macos-defaults.sh

custom: ## Run optional custom scripts
	@bash ./scripts/run-custom.sh

git-monorepo: ## Optimize a large monorepo (REPO=/path/to/repo)
	@bash ./scripts/git-monorepo.sh "$(REPO)"

refresh: ## Brew update + restow
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Refreshing$(RESET)\n"
	@printf "  $(DIM)Updating Homebrew...$(RESET)\n"
	@command -v brew >/dev/null 2>&1 && brew update && brew upgrade || true
	@$(MAKE) stow

mise-install: ## Install language runtimes from mise config
	@printf "\n$(BLUE)$(BOLD)==>$(RESET) $(BOLD)Installing runtimes$(RESET)\n"
	@command -v mise >/dev/null 2>&1 || { printf "  $(RED)mise not found. Run 'make brew' first.$(RESET)\n"; exit 1; }
	@mise install --yes 2>&1 | while read -r line; do printf "  $(DIM)%s$(RESET)\n" "$$line"; done || true
	@printf "  $(GREEN)Runtimes installed$(RESET)\n"

doctor: ## Print environment diagnostics
	@printf "\n  $(MAUVE)$(BOLD)Doctor$(RESET)\n\n"
	@for tool in brew git stow zsh mise node python3 ruby go rustc nvim gh glab; do \
		if command -v $$tool >/dev/null 2>&1; then \
			ver=$$($$tool --version 2>/dev/null | head -1 || echo "ok"); \
			printf "  $(GREEN)%-12s$(RESET) %s\n" "$$tool" "$$ver"; \
		else \
			printf "  $(RED)%-12s$(RESET) %s\n" "$$tool" "missing"; \
		fi; \
	done
	@printf "\n"

nuke: ## Full reset: unstow, remove oh-my-zsh, re-bootstrap
	@printf "\n  $(RED)$(BOLD)WARNING$(RESET) This will unstow dotfiles, remove ~/.oh-my-zsh, and rerun bootstrap.\n\n"
	@read -r -p "  Type 'yes' to continue: " answer; \
	[ "$$answer" = "yes" ] || { printf "  $(DIM)Aborted.$(RESET)\n"; exit 1; }
	@$(MAKE) unstow
	@rm -rf "$$HOME/.oh-my-zsh"
	@$(MAKE) bootstrap
