# CLI Tools

Every tool installed via `brew/Brewfile.base` and `brew/Brewfile.apps`.

## Core CLI (`Brewfile.base`)

### Git & Version Control

| Tool | Description |
|------|-------------|
| [git](https://git-scm.com) | Version control |
| [git-delta](https://github.com/dandavison/delta) | Better git diff viewer with syntax highlighting |
| [git-cliff](https://github.com/orhun/git-cliff) | Changelog generator from conventional commits |
| [gh](https://cli.github.com) | GitHub CLI |
| [glab](https://gitlab.com/gitlab-org/cli) | GitLab CLI |
| [lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git |

### Search & Navigation

| Tool | Description |
|------|-------------|
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | Fast recursive grep replacement |
| [fd](https://github.com/sharkdp/fd) | Fast find replacement |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for files, history, processes |
| [zoxide](https://github.com/ajeetdsouza/zoxide) (`z`) | Smarter cd with frecency tracking |
| [yazi](https://yazi-rs.github.io) (`y`) | Terminal file manager |
| [tree](https://mama.indstate.edu/users/ice/tree/) | Directory tree viewer |

### File Viewing & Editing

| Tool | Description |
|------|-------------|
| [bat](https://github.com/sharkdp/bat) | cat with syntax highlighting (Catppuccin theme) |
| [eza](https://github.com/eza-community/eza) | Modern ls replacement with git status |
| [neovim](https://neovim.io) (`nvim`) | Modern vim with LazyVim config |

### System Monitoring

| Tool | Description |
|------|-------------|
| [bottom](https://github.com/ClementTsang/bottom) (`btm`) | Better top/htop |
| [procs](https://github.com/dalance/procs) | Better ps with color and tree view |
| [dust](https://github.com/bootandy/dust) | Better du (disk usage visualization) |

### Development

| Tool | Description |
|------|-------------|
| [mise](https://mise.jdx.dev) | Runtime version manager (Ruby, Node, Python, Go, Rust) |
| [direnv](https://direnv.net) | Per-directory environment variables |
| [jq](https://jqlang.github.io/jq/) | JSON processor |
| [httpie](https://httpie.io) | Better curl for APIs |
| [xh](https://github.com/ducaale/xh) | Even faster httpie-compatible HTTP client |
| [hyperfine](https://github.com/sharkdp/hyperfine) | CLI benchmarking |
| [tokei](https://github.com/XAMPPRocky/tokei) | Code statistics |
| [gemini-cli](https://github.com/google-gemini/gemini-cli) | Google Gemini CLI |

### Infrastructure

| Tool | Description |
|------|-------------|
| [kubectl](https://kubernetes.io/docs/reference/kubectl/) | Kubernetes CLI |
| [helm](https://helm.sh) | Kubernetes package manager |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Docker TUI |
| [ansible](https://www.ansible.com) | Automation/config management |

### Shell & Prompt

| Tool | Description |
|------|-------------|
| [starship](https://starship.rs) | Cross-shell prompt with Catppuccin colors |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like autosuggestions for zsh |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Syntax highlighting for zsh |
| [atuin](https://atuin.sh) | Shell history with sync (Ctrl+R) |

### Utilities

| Tool | Description |
|------|-------------|
| [stow](https://www.gnu.org/software/stow/) | Symlink farm manager for dotfiles |
| [tlrc](https://github.com/tldr-pages/tlrc) | Rust tldr client (command examples) |
| [watchman](https://facebook.github.io/watchman/) | File watcher |
| [dockutil](https://github.com/kcrawford/dockutil) | macOS Dock management |
| [coreutils](https://www.gnu.org/software/coreutils/) | GNU core utilities |
| [wget](https://www.gnu.org/software/wget/) | File downloader |

## GUI Apps (`Brewfile.apps`)

| App | Description |
|-----|-------------|
| [Ghostty](https://ghostty.org) | GPU-accelerated terminal emulator |
| [Obsidian](https://obsidian.md) | Markdown knowledge base |
| [draw.io](https://www.drawio.com) | Diagramming tool |

### Fonts

- JetBrains Mono
- JetBrains Mono Nerd Font
- Symbols Only Nerd Font
- Fira Code Nerd Font

## Language Runtimes (via mise)

Configured in `dotfiles/mise/.config/mise/config.toml`:

| Runtime | Version |
|---------|---------|
| Ruby | 4 |
| Node | lts |
| Python | 3.14 |
| Go | 1.25 |
| Rust | stable |
