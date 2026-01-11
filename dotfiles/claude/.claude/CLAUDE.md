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

## Claude Code Setup

### Enabled Plugins

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

### Key Skills

- `/feature-dev` - Start guided feature development
- `/commit` - Create git commit
- `/commit-push-pr` - Commit, push, and open PR
- `/code-review` - Review a pull request
- `/review-pr` - Comprehensive PR review with agents

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

### Shell Helpers

- `m` - Run `make` from nearest Makefile
- `mt` - FZF picker for make targets
- `gpm` / `gpm1` - Prep merge onto default branch
- `gmr` - Create GitLab MR

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
