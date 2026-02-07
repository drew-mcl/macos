# macos

a beautiful, opinionated dev workstation — made with ❤️

## setup

your full dev environment, from nothing, in one command.
catppuccin-themed, CLI-first, and configured like you spent weeks on it.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/drew-mcl/macos/main/install.sh)
```

## ws

```bash
ws zsh       # edit shell config
ws brew      # edit brewfiles
ws git       # edit git config
ws nvim      # edit neovim config
ws edit      # fzf picker for any file
ws sync      # commit + push changes
ws stow      # re-symlink all dotfiles
ws doctor    # check for drift
ws update    # brew update + restow
ws profile   # shell startup timing
```

run `ws help` for all commands.

## make

run `make` in the repo to see all targets.

## [docs](docs/README.md)

- [bootstrap guide](docs/bootstrap.md)
- [cli tools](docs/cli-tools.md)
- [shell reference](docs/shell.md)
- [catppuccin theme](docs/catppuccin.md)
- [lazyvim cheatsheet](docs/lazyvim-cheatsheet.md)
