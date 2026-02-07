# Catppuccin Macchiato Theme

All terminal tools use the [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin) flavor for a unified visual identity.

## Configured Tools

| Tool | Config Location | Method |
|------|----------------|--------|
| Ghostty | `dotfiles/ghostty/.config/ghostty/config` | `theme = catppuccin-macchiato` |
| Neovim | `dotfiles/nvim/.config/nvim/lua/plugins/catppuccin.lua` | catppuccin/nvim plugin |
| bat | `dotfiles/zsh/.zshrc` | `BAT_THEME="Catppuccin Macchiato"` |
| fzf | `dotfiles/zsh/.zshrc` | `FZF_DEFAULT_OPTS` color flags |
| git-delta | `dotfiles/git/.gitconfig` | `syntax-theme = Catppuccin Macchiato` |
| lazygit | `dotfiles/lazygit/.config/lazygit/config.yml` | GUI theme colors |
| Starship | `dotfiles/starship/.config/starship.toml` | Hex color codes on modules |
| Yazi | `dotfiles/yazi/.config/yazi/yazi.toml` | `[flavor] use = "catppuccin-macchiato"` |
| bottom | via alias in `.zshrc` | `btm --color gruvbox` (closest match) |

## Changing the Flavor

To switch from Macchiato to another Catppuccin flavor (Latte, Frappe, Mocha):

1. **Ghostty**: Change `theme = catppuccin-macchiato` to `catppuccin-<flavor>`
2. **Neovim**: Change `flavour = "macchiato"` and `colorscheme = "catppuccin-macchiato"` in `catppuccin.lua`
3. **bat**: Change `BAT_THEME` in `.zshrc`
4. **fzf**: Update hex colors in `FZF_DEFAULT_OPTS` (see [catppuccin/fzf](https://github.com/catppuccin/fzf))
5. **git-delta**: Change `syntax-theme` in `.gitconfig`
6. **lazygit**: Update hex colors in `config.yml` (see [catppuccin/lazygit](https://github.com/catppuccin/lazygit))
7. **Starship**: Update hex colors in `starship.toml`
8. **Yazi**: Change `use = "catppuccin-macchiato"` in `yazi.toml`

Then run `ws stow` to re-symlink and restart your terminal.

## Catppuccin Macchiato Palette

Key colors used across configs:

| Name | Hex | Usage |
|------|-----|-------|
| Rosewater | `#f4dbd6` | Cursor, pointer |
| Red | `#ed8796` | Errors, highlights |
| Peach | `#f5a97f` | Command duration |
| Yellow | `#eed49f` | Warnings, git status |
| Green | `#a6da95` | Success, git branch |
| Blue | `#8aadf4` | Info, directory |
| Lavender | `#b7bdf8` | Markers |
| Mauve | `#c6a0f6` | Prompts, info |
| Text | `#cad3f5` | Default foreground |
| Subtext0 | `#a5adcb` | Inactive borders |
| Surface0 | `#363a4f` | Selection background |
| Surface1 | `#494d64` | Selected background |
| Base | `#24273a` | Background |

## Yazi Flavor Installation

The Yazi Catppuccin flavor is installed automatically by `make stow` (via `ya pack`). To reinstall manually:

```bash
ya pack -a yazi-rs/flavors:catppuccin-macchiato
```
