# CLAUDE.md

This file provides global guidance to Claude Code (claude.ai/code) across all repositories.

## Claude Code Workflow

### Feature Development

**Always use the `/feature-dev` skill** for new features or significant changes. This ensures proper planning, architecture review, and implementation.

### Git Worktrees

**Always use git worktrees** for feature development - never work directly on main:

```bash
# Create worktree for a feature
git worktree add ../repo-feature-name -b feature-name

# Or with Linear issue
git worktree add ../repo-eng-123 -b drew/eng-123-feature-name

# List worktrees
git worktree list

# Remove worktree when done (after merge)
git worktree remove ../repo-feature-name
```

**On completion**: Always clean up worktrees after PR is merged. Use `git worktree remove <path>` or `git worktree prune` for stale entries.

### Linear Integration

**PR/MR titles**: Include Linear issue ID in the title
```
ENG-123: feat(auth): add OAuth2 login flow
```

**PR/MR descriptions**: Use magic words to auto-link and close issues
```
Fixes ENG-123

## Summary
...
```

**Magic words** (trigger auto-close on merge): `close`, `closes`, `fix`, `fixes`, `resolve`, `resolves`, `complete`, `completes`

**Non-closing words** (link without auto-close): `ref`, `references`, `part of`, `related to`, `contributes to`

**Branch naming**: Use Linear's branch format: `username/eng-123-short-description`

### Commit Format

When Linear issues are used:
```
ENG-123: feat(scope): description

Body with details...
```

Without Linear:
```
feat(scope): description
```

**Never include co-authored-by lines.**

## Claude Code Plugins

| Plugin | Purpose |
|--------|---------|
| `feature-dev` | Guided feature development with architecture focus |
| `commit-commands` | Git commit, push, PR workflows |
| `code-review` | Code review for PRs |
| `pr-review-toolkit` | Comprehensive PR review agents |
| `code-simplifier` | Refactoring and cleanup |
| `hookify` | Create hooks to prevent unwanted behaviors |
| `context7` | Up-to-date library documentation |
| `playwright` | Browser automation and testing |
| `linear` | Linear issue management |
| `sentry` | Error tracking integration |
| `supabase` | Supabase database/auth tools |
| `security-guidance` | Security best practices |
| `frontend-design` | UI/frontend development |

### MCP Servers

- **Linear**: Issue tracking, project management
- **Sentry**: Error monitoring, issue analysis
- **Supabase**: Database queries, auth management
- **Playwright**: Browser automation
- **Context7**: Library documentation lookup

### Skills

| Skill | Description |
|-------|-------------|
| `/feature-dev` | Start guided feature development |
| `/commit` | Create git commit |
| `/commit-push-pr` | Commit, push, and open PR |
| `/code-review` | Review a pull request |
| `/review-pr` | Comprehensive PR review with agents |

## Available CLI Tools

### Git & Version Control

| Tool | Description |
|------|-------------|
| `git` | Version control |
| `git-delta` | Better git diff viewer |
| `git-cliff` | Changelog generator |
| `gh` | GitHub CLI |
| `glab` | GitLab CLI |
| `lazygit` | Terminal UI for git |

### Search & Navigation

| Tool | Description |
|------|-------------|
| `ripgrep` (`rg`) | Fast grep replacement |
| `fd` | Fast find replacement |
| `fzf` | Fuzzy finder |
| `zoxide` (`z`) | Smarter cd with frecency |
| `yazi` (`y`) | Terminal file manager |
| `tree` | Directory tree viewer |

### File Viewing & Editing

| Tool | Description |
|------|-------------|
| `bat` | cat with syntax highlighting |
| `eza` | Modern ls replacement |
| `neovim` (`nvim`) | Modern vim |

### System Monitoring

| Tool | Description |
|------|-------------|
| `bottom` (`btm`) | Better top/htop |
| `procs` | Better ps |
| `dust` | Better du (disk usage) |

### Development

| Tool | Description |
|------|-------------|
| `mise` | Runtime version manager (ruby, node, python, go) |
| `direnv` | Per-directory environment variables |
| `jq` | JSON processor |
| `httpie` / `xh` | Better curl for APIs |
| `hyperfine` | CLI benchmarking |
| `tokei` | Code statistics |

### Infrastructure

| Tool | Description |
|------|-------------|
| `kubectl` | Kubernetes CLI |
| `helm` | Kubernetes package manager |
| `lazydocker` | Docker TUI |
| `ansible` | Automation/config management |

### Utilities

| Tool | Description |
|------|-------------|
| `stow` | Symlink farm manager |
| `tlrc` | tldr pages (command examples) |
| `watchman` | File watcher |
| `atuin` | Shell history with sync (Ctrl+R) |
| `starship` | Cross-shell prompt |

## Shell Aliases

### Git

| Alias | Expansion |
|-------|-----------|
| `gs` | `git status -sb` |
| `gco` | `git checkout` |
| `gb` | `git branch -vv` |
| `gl` | `git log --oneline --graph --decorate` |
| `gd` | `git diff` |
| `gp` | `git pull --ff-only && git push` |
| `gpm` | `git prep-merge` (interactive rebase onto default) |
| `gpm1` | `git prep-merge-squash` (squash to one commit) |

### GitLab

| Alias | Description |
|-------|-------------|
| `gmr` | Create MR with `--fill --remove-source-branch` |
| `gml` | List MRs assigned to me |
| `gms` | MR status |
| `gci` | View CI pipeline |
| `gmco` | FZF picker to checkout an open MR |

### Modern Replacements

| Alias | Actual Command |
|-------|----------------|
| `cat` | `bat --paging=never` |
| `less` | `bat` |
| `du` | `dust` |
| `ps` | `procs` |
| `top`/`htop` | `btm` |
| `vim`/`vi` | `nvim` |
| `ll` | `eza -lah --git` |

### Ruby

| Alias | Description |
|-------|-------------|
| `be` | `bundle exec` |

## Shell Functions

| Function | Description |
|----------|-------------|
| `m [target]` | Run make from nearest parent Makefile |
| `mt` | FZF picker for make targets |
| `y` | Yazi file manager (cd on exit) |
| `z <dir>` | Zoxide smart cd |
| `sshx` | FZF SSH host picker from config |
| `ssh-host <host>` | Generate per-host SSH key + config |
| `repo` | FZF browse + clone GitHub/GitLab repos |
| `aa` | FZF alias browser |
| `envim` | Open nearest .env file in nvim |
| `code-dotfiles` | Open dotfiles repo in VS Code |

## Development Workflows

### Rails Applications

```bash
bin/setup              # Install dependencies, prepare database, start server
bin/dev                # Start Rails + asset watchers (via Foreman)
bin/rails test         # Run all tests
bin/ci                 # Run full CI suite
bin/rubocop            # Ruby style linter
bin/kamal deploy       # Deploy via Kamal
```

### Ruby Conventions

- **Framework**: Minitest with `ActiveSupport::TestCase`
- **Fixtures**: Located in `test/fixtures/`
- **File structure**: Mirror app in tests (`app/models/user.rb` → `test/models/user_test.rb`)

### Common Patterns

**ViewComponent**
- Components in `app/components/`
- In `.rb`: Call helpers directly
- In `.html.erb`: Use `helpers.` prefix

**Multi-Database Rails**
- Primary: PostgreSQL
- Solid adapters: SQLite for Cache/Queue/Cable

### Design Guidelines

- **No emojis in code** - Use icon helpers
- **Keep code idempotent** - Safe to re-run

## Task Tracking

**Always use Task tools** (TaskCreate, TaskUpdate, TaskList) instead of TodoWrite for tracking work items. The Task tools provide better progress visibility and persist across sessions.

Environment variable required in shell profile:
```bash
export CLAUDE_CODE_ENABLE_TASKS=true
```
