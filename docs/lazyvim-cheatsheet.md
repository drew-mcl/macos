# LazyVim Cheatsheet

Quick reference for LazyVim keybindings and features.

## Leader Key

The leader key is `<Space>`. Most commands start with it.

---

## File Navigation

| Keybinding | Action |
|------------|--------|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fr` | Recent files |
| `<leader>fb` | Browse buffers |
| `<leader>fg` | Live grep (search in files) |
| `<leader>e` | File explorer (neo-tree) |
| `<leader><leader>` | Find buffers |

---

## Window Management

| Keybinding | Action |
|------------|--------|
| `<C-h/j/k/l>` | Navigate between windows |
| `<leader>-` | Split window below |
| `<leader>\|` | Split window right |
| `<leader>wd` | Delete window |
| `<leader>wm` | Maximize window |

---

## Buffer Management

| Keybinding | Action |
|------------|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Delete other buffers |
| `<leader>bp` | Pin buffer |

---

## Code Navigation (LSP)

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format document |
| `]d` / `[d` | Next/prev diagnostic |
| `<leader>cd` | Line diagnostics |

---

## Text Selection

### Treesitter Incremental Selection
| Keybinding | Action |
|------------|--------|
| `<C-space>` | Start/expand selection (smart) |
| `<BS>` | Shrink selection (in visual mode) |

### Indent-based (great for YAML/Python)
| Keybinding | Action |
|------------|--------|
| `vii` | Select inside indent |
| `vai` | Select around indent |

### Treesitter Text Objects
| Keybinding | Action |
|------------|--------|
| `vaf` / `vif` | Around/inside function |
| `vac` / `vic` | Around/inside class |
| `vaa` / `via` | Around/inside argument |
| `va=` / `vi=` | Around/inside assignment |

### Surround Operations
| Keybinding | Action |
|------------|--------|
| `ys{motion}{char}` | Add surround |
| `ds{char}` | Delete surround |
| `cs{old}{new}` | Change surround |

---

## Search & Replace

| Keybinding | Action |
|------------|--------|
| `<leader>sr` | Search and replace (Spectre) |
| `<leader>sw` | Search word under cursor |
| `n` / `N` | Next/prev search result |
| `*` / `#` | Search word forward/backward |

---

## Git

| Keybinding | Action |
|------------|--------|
| `<leader>gg` | Lazygit |
| `<leader>gf` | Git files |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `<leader>gb` | Git blame line |
| `]h` / `[h` | Next/prev hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghs` | Stage hunk |

---

## Terminal

| Keybinding | Action |
|------------|--------|
| `<C-/>` | Toggle terminal |
| `<leader>ft` | Terminal (floating) |
| `<leader>fT` | Terminal (cwd) |

---

## Comments

| Keybinding | Action |
|------------|--------|
| `gc` | Toggle comment (motion) |
| `gcc` | Toggle comment line |
| `gco` | Add comment below |
| `gcO` | Add comment above |

---

## Folding

| Keybinding | Action |
|------------|--------|
| `za` | Toggle fold |
| `zc` | Close fold |
| `zo` | Open fold |
| `zM` | Close all folds |
| `zR` | Open all folds |

---

## UI Toggles

| Keybinding | Action |
|------------|--------|
| `<leader>uf` | Toggle format on save |
| `<leader>us` | Toggle spelling |
| `<leader>uw` | Toggle word wrap |
| `<leader>ul` | Toggle line numbers |
| `<leader>ud` | Toggle diagnostics |
| `<leader>uc` | Toggle conceal |
| `<leader>uC` | Toggle colorizer |

---

## Useful Commands

| Command | Action |
|---------|--------|
| `:Lazy` | Open plugin manager |
| `:Mason` | Open LSP/linter installer |
| `:LazyExtras` | Enable/disable LazyVim extras |
| `:checkhealth` | Diagnose issues |
| `:Telescope keymaps` | Search all keybindings |

---

## Quick Tips

- **Find any keybinding**: `<leader>sk` opens keymap search
- **Command palette**: `<leader>:` for command history
- **Which-key**: Press `<leader>` and wait for popup guide
- **Help**: `:h <topic>` for Neovim help

---

## Motions Refresher

| Motion | Action |
|--------|--------|
| `w` / `b` | Word forward/back |
| `e` / `ge` | End of word forward/back |
| `f{char}` / `F{char}` | Find char forward/back |
| `t{char}` / `T{char}` | Till char forward/back |
| `;` / `,` | Repeat f/t forward/back |
| `%` | Matching bracket |
| `gg` / `G` | Start/end of file |
| `{` / `}` | Paragraph up/down |
| `H` / `M` / `L` | Screen top/middle/bottom |
