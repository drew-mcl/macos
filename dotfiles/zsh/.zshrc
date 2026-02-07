# shellcheck disable=SC1090

# --- Homebrew ----------------------------------------------------------------
if [[ -z ${HOMEBREW_PREFIX:-} ]]; then
  for brew_candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "${brew_candidate}" ]]; then
      eval "$("${brew_candidate}" shellenv)"
      break
    fi
  done
fi

typeset -gU path PATH
path=("$HOME/.bundle/bin" "$HOME/.local/bin" $path)

path_prepend_if_exists() {
  local dir
  for dir in "$@"; do
    [[ -n $dir && -d $dir ]] || continue
    path=("$dir" $path)
  done
}

# --- History & editing -------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt AUTO_CD
setopt EXTENDED_GLOB
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt CORRECT

bindkey -e
export ENABLE_CORRECTION="true"
export SPROMPT='zsh: correct %F{yellow}%R%f to %F{green}%r%f [nyae]? '

# --- Catppuccin Macchiato palette for CLI tools ------------------------------
export BAT_THEME="Catppuccin Macchiato"
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
  --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
  --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 \
  --color=selected-bg:#494d64 \
  --border=rounded --prompt='> ' --pointer='◆' --marker='>' \
  --separator='─' --scrollbar='│' --info=right"

# --- Oh My Zsh & plugins -----------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git fzf)

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if command -v brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix 2>/dev/null)"
  if [[ -n $brew_prefix ]]; then
    asugg="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [[ -r $asugg ]] && source "$asugg"
    synhl="$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    [[ -r $synhl ]] && source "$synhl"
    fzf_dir="$brew_prefix/opt/fzf"
    [[ -r "$fzf_dir/shell/key-bindings.zsh" ]] && source "$fzf_dir/shell/key-bindings.zsh"
    [[ -r "$fzf_dir/shell/completion.zsh" ]] && source "$fzf_dir/shell/completion.zsh"
  fi
  unset brew_prefix asugg synhl fzf_dir
fi

# --- Tooling hooks -----------------------------------------------------------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v go >/dev/null 2>&1; then
  export GOPATH="${GOPATH:-$HOME/go}"
  export GOBIN="$GOPATH/bin"
  path_prepend_if_exists "$GOBIN"
fi

# --- zoxide (smarter cd) -----------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# --- atuin (shell history) ---------------------------------------------------
# Binds to Ctrl+R only, preserving up arrow for zsh-autosuggestions
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# --- yazi (file manager with cd on exit) -------------------------------------
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- Prompt ------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
else
  PROMPT='%n@%m %1~ %# '
fi

# --- Aliases -----------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
  alias ll='eza -lah --git --group-directories-first'
else
  alias ll='ls -lah'
fi
alias gs='git status -sb'
alias gco='git checkout'
alias gb='git branch -vv'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gp='git pull --ff-only && git push'
alias gpm='git prep-merge'
alias gpm1='git prep-merge-squash'
alias be='bundle exec'

# Modern CLI aliases
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=never'
  alias less='bat'
fi
if command -v dust >/dev/null 2>&1; then
  alias du='dust'
fi
if command -v procs >/dev/null 2>&1; then
  alias ps='procs'
fi
if command -v btm >/dev/null 2>&1; then
  alias top='btm --color gruvbox'
  alias htop='btm --color gruvbox'
fi
alias vim='nvim'
alias vi='nvim'
alias clc='claude --dangerously-skip-permissions'

if command -v glab >/dev/null 2>&1; then
  alias gmr='glab mr create --fill --remove-source-branch'
  alias gml='glab mr list --mine'
  alias gms='glab mr status'
  alias gci='glab ci view'

  gmco() {
    command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
    local line id
    line=$(glab mr list --state opened --no-headers -n 100 2>/dev/null | fzf --ansi --prompt='MR> ' --height=60%) || return 1
    id=$(echo "$line" | awk '{print $1}')
    [[ -n $id ]] || return 1
    glab mr checkout "$id"
  }
fi

# --- Helpers -----------------------------------------------------------------
m() {
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -f "$dir/Makefile" ]]; do
    dir="${dir:h}"
  done
  if [[ ! -f "$dir/Makefile" ]]; then
    echo "No Makefile found" >&2
    return 1
  fi
  (cd "$dir" && make "$@")
}

mt() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local dir="$PWD"
  while [[ "$dir" != "/" && ! -f "$dir/Makefile" ]]; do
    dir="${dir:h}"
  done
  if [[ ! -f "$dir/Makefile" ]]; then
    echo "No Makefile found" >&2
    return 1
  fi
  local target
  target=$(
    make -qp -C "$dir" 2>/dev/null |
      awk -F':' '/^[[:alnum:]][^$#\/\t=]*:([^=]|$)/ {print $1}' |
      sort -u |
      fzf --prompt='make> ' --height=60%
  ) || return 1
  (cd "$dir" && make "$target")
}

aa() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local selection name body
  selection=$(alias | fzf --prompt='alias> ' --preview 'echo {}' --height=60%) || return 1
  name=${selection#alias }
  name=${name%%=*}
  body=${selection#*=}
  body=${body#\'}
  body=${body%\'}
  body=${body#\"}
  body=${body%\"}
  print -z -- "$body"
}

sshx() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local -a config_files=()
  [[ -f "$HOME/.ssh/config" ]] && config_files+=("$HOME/.ssh/config")
  if [[ -d "$HOME/.ssh/config.d" ]]; then
    config_files+=("$HOME/.ssh/config.d"/*(.N))
  fi
  (( ${#config_files[@]} )) || { echo "No SSH config files found" >&2; return 1; }
  local hosts host
  hosts=$(awk '/^Host /{for(i=2;i<=NF;i++) if ($i !~ /[\*\?]/) print $i}' "${config_files[@]}" 2>/dev/null | sort -u)
  [[ -n $hosts ]] || { echo "No SSH hosts found" >&2; return 1; }
  host=$(printf '%s\n' "$hosts" | fzf --prompt='ssh> ' --height=60%) || return 1
  [[ -n $host ]] && ssh "$host"
}

ssh-host() {
  local script
  if [[ -x "${MACOS_SETUP:-$HOME/repos/macos}/scripts/ssh-host.sh" ]]; then
    script="${MACOS_SETUP:-$HOME/repos/macos}/scripts/ssh-host.sh"
  elif [[ -x "$PWD/scripts/ssh-host.sh" ]]; then
    script="$PWD/scripts/ssh-host.sh"
  else
    echo "ssh-host.sh script not found" >&2
    return 1
  fi
  bash "$script" "$@"
}

envim() {
  local dir="$PWD" envfile
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.env" ]]; then
      envfile="$dir/.env"
      break
    fi
    dir="${dir:h}"
  done
  if [[ -z $envfile ]]; then
    echo "No .env file found" >&2
    return 1
  fi
  nvim "$envfile"
}

repo() {
  command -v fzf >/dev/null 2>&1 || { echo "fzf not installed" >&2; return 1; }
  local -a rows=()
  if command -v gh >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    while IFS=$'\t' read -r name url; do
      rows+=("github\t${name}\t${url}")
    done < <(gh repo list --limit 500 --json nameWithOwner,sshUrl 2>/dev/null | jq -r '.[] | [.nameWithOwner, .sshUrl] | @tsv')
  fi
  if command -v glab >/dev/null 2>&1; then
    while read -r line; do
      local path
      path=$(echo "$line" | awk '{print $1}')
      [[ -z $path ]] && continue
      rows+=("gitlab\t${path}\tgit@gitlab.com:${path}.git")
    done < <(glab repo list --no-headers -n 200 2>/dev/null || true)
  fi
  (( ${#rows[@]} )) || { echo "No repos found via gh or glab" >&2; return 1; }
  local selection name url destination_dir
  selection=$(printf '%s\n' "${rows[@]}" | column -t -s $'\t' | fzf --ansi --prompt='repo> ' --height=80% --preview 'echo {1} {2}\n{3}') || return 1
  name=$(echo "$selection" | awk '{print $2}')
  url=$(echo "$selection" | awk '{print $3}')
  destination_dir="$HOME/repos/${name##*/}"
  if [[ -d "$destination_dir/.git" ]]; then
    echo "Exists: $destination_dir"
    cd "$destination_dir"
    return 0
  fi
  git clone "$url" "$destination_dir" && cd "$destination_dir"
}

# --- ws: workstation config manager ------------------------------------------
ws() {
  local WS="${MACOS_SETUP:-$HOME/repos/macos}"
  case "${1:-help}" in
    brew)     $EDITOR "$WS/brew/Brewfile.base" ;;
    zsh)      $EDITOR "$WS/dotfiles/zsh/.zshrc" ;;
    env)      $EDITOR "$WS/dotfiles/zsh/.zshenv" ;;
    git)      $EDITOR "$WS/dotfiles/git/.gitconfig" ;;
    ghostty)  $EDITOR "$WS/dotfiles/ghostty/.config/ghostty/config" ;;
    nvim)     $EDITOR "$WS/dotfiles/nvim/.config/nvim/" ;;
    mise)     $EDITOR "$WS/dotfiles/mise/.config/mise/config.toml" ;;
    star)     $EDITOR "$WS/dotfiles/starship/.config/starship.toml" ;;
    ssh)      $EDITOR "$WS/dotfiles/ssh/.ssh/config" ;;
    claude)   $EDITOR "$WS/dotfiles/claude/.claude/CLAUDE.md" ;;
    edit)     fd . "$WS" -H --type f -E .git | fzf --preview 'bat --color=always {}' | xargs -r $EDITOR ;;
    sync)     git -C "$WS" add -A && git -C "$WS" commit -m "sync: $(date +%Y-%m-%d-%H%M)" && git -C "$WS" push ;;
    stow)     make -C "$WS" stow ;;
    doctor)
      echo "=== Brew Drift ==="
      brew bundle check --file="$WS/brew/Brewfile.base" 2>&1 || true
      brew bundle check --file="$WS/brew/Brewfile.apps" 2>&1 || true
      echo ""
      echo "=== Mise Drift ==="
      mise doctor 2>&1 | head -20
      echo ""
      echo "=== Stow Status ==="
      for pkg in $WS/dotfiles/*/; do
        local pkg_name=$(basename "$pkg")
        stow --no-folding --simulate -d "$WS/dotfiles" -t "$HOME" "$pkg_name" 2>&1 | grep -v "^$" && echo "  $pkg_name: needs restow" || true
      done
      echo ""
      echo "=== Tool Versions ==="
      make -C "$WS" doctor
      ;;
    update)   make -C "$WS" refresh ;;
    profile)
      echo "=== Shell startup time ==="
      for i in 1 2 3; do
        /usr/bin/time zsh -i -c exit 2>&1
      done
      echo ""
      echo "=== Detailed trace (first 50 lines) ==="
      zsh -xvs -i -c exit 2>&1 | head -50
      ;;
    help|*)
      printf "\n  \033[38;5;141m\033[1mws\033[0m \033[2mworkstation config manager\033[0m\n\n"
      printf "  \033[36m%-12s\033[0m %s\n" "brew"    "Edit Brewfile"
      printf "  \033[36m%-12s\033[0m %s\n" "zsh"     "Edit .zshrc"
      printf "  \033[36m%-12s\033[0m %s\n" "env"     "Edit .zshenv"
      printf "  \033[36m%-12s\033[0m %s\n" "git"     "Edit .gitconfig"
      printf "  \033[36m%-12s\033[0m %s\n" "ghostty" "Edit Ghostty config"
      printf "  \033[36m%-12s\033[0m %s\n" "nvim"    "Edit Neovim config"
      printf "  \033[36m%-12s\033[0m %s\n" "mise"    "Edit mise runtime versions"
      printf "  \033[36m%-12s\033[0m %s\n" "star"    "Edit Starship prompt"
      printf "  \033[36m%-12s\033[0m %s\n" "ssh"     "Edit SSH config"
      printf "  \033[36m%-12s\033[0m %s\n" "claude"  "Edit global CLAUDE.md"
      printf "  \033[36m%-12s\033[0m %s\n" "edit"    "FZF picker for any config"
      printf "  \033[36m%-12s\033[0m %s\n" "sync"    "Commit + push changes"
      printf "  \033[36m%-12s\033[0m %s\n" "stow"    "Re-stow all packages"
      printf "  \033[36m%-12s\033[0m %s\n" "doctor"  "Diagnostics + drift check"
      printf "  \033[36m%-12s\033[0m %s\n" "update"  "Brew update + restow"
      printf "  \033[36m%-12s\033[0m %s\n" "profile" "Shell startup profiling"
      printf "\n"
      ;;
  esac
}

_ws() {
  local commands=(brew zsh env git ghostty nvim mise star ssh claude edit sync stow doctor update profile help)
  _describe 'ws commands' commands
}
compdef _ws ws

# --- obsidian-sync -----------------------------------------------------------
obsidian-sync() {
  local vault="${OBSIDIAN_VAULT:-$HOME/Documents/Obsidian}"
  if [[ ! -d "$vault/.git" ]]; then
    echo "Initializing git repo in $vault..."
    git -C "$vault" init
    git -C "$vault" remote add origin git@github.com:drew-mcl/obsidian.git
    git -C "$vault" branch -M main
  fi
  git -C "$vault" add -A
  git -C "$vault" commit -m "vault sync: $(date +%Y-%m-%d-%H%M)" || echo "Nothing to sync"
  git -C "$vault" push -u origin main
}

# --- opencode ----------------------------------------------------------------
export PATH=/Users/drew/.opencode/bin:$PATH

# --- Start in repos ----------------------------------------------------------
cd ~/repos 2>/dev/null || true
