# CLAUDE.md

This file provides global guidance to Claude Code (claude.ai/code) across all repositories.

## Development Workflows

### Rails Applications

**Setup & Running**
```bash
bin/setup              # Install dependencies, prepare database, start server
bin/setup --reset      # Reset database first, then setup
bin/dev                # Start Rails + asset watchers (via Foreman)
```

**Database Management**
```bash
bin/reset-db                    # Run migrations
bin/reset-db --reset            # Drop/recreate database
bin/reset-db --seed             # Run migrations + seed data
bin/reset-db --reset --seed     # Full reset with seed data
bin/reset-db --test             # Run test migrations
```

**Testing**
```bash
bin/rails test                              # Run all tests
bin/rails test test/models/user_test.rb    # Run specific test file
bin/rails test test/models/user_test.rb:23 # Run specific test line
bin/ci                                      # Run full CI suite
```

**Code Quality**
```bash
bin/rubocop           # Ruby style linter
bin/brakeman          # Security vulnerability scanner
bin/bundler-audit     # Check for vulnerable gems
```

**Kamal Deployment**
```bash
bin/kamal setup       # First-time deployment
bin/kamal deploy      # Deploy updates
bin/kamal console     # Open Rails console on production
bin/kamal logs        # View production logs
bin/kamal shell       # SSH into production container
```

### Ruby Conventions

- **Framework**: Minitest with `ActiveSupport::TestCase`
- **Fixtures**: Located in `test/fixtures/` (auto-loaded)
- **Test naming**: Descriptive names like `test_valid_slug_is_imported`
- **File structure**: Mirror app structure in tests (`app/models/user.rb` → `test/models/user_test.rb`)

### Git Workflow

**Conventional Commits**
- `feat(scope):` - New features
- `fix(scope):` - Bug fixes
- `refactor(scope):` - Code restructuring
- `docs(scope):` - Documentation changes
- `test(scope):` - Test additions/changes

**Helper Commands** (from zsh config)
- `gpm` / `gpm1` - Prep merge / squash merge onto default branch
- `gmr` - Create GitLab MR with `--fill --remove-source-branch`
- `gml` - List my MRs
- `gms` - MR status
- `gci` - View CI pipeline

### Make-Driven Projects

**Helper Functions**
- `m` - Run `make` from nearest parent directory with Makefile
- `mt` - FZF picker for make targets

### Common Patterns

**Multi-Database Rails Setup**
- Primary: PostgreSQL (main app data)
- Solid adapters: SQLite for Solid Cache/Queue/Cable in production
- Check `config/database.yml` for connection names

**Active Storage Service Switching**
- Check if blob service matches current config before displaying images
- Use helper methods like `cover_image_usable?` to verify compatibility

**ViewComponent Usage**
- Components in `app/components/`
- Previews at `/lookbook` in development
- In `.rb` files: Call helpers directly (included via ApplicationComponent)
- In `.html.erb` templates: Use `helpers.` prefix (e.g., `helpers.icon("search")`)

### Design Guidelines

- **No emojis in code**: Use icon helpers for all iconography
- **Icon consistency**: Use SVG icons via helper functions
- **Keep code idempotent**: Scripts and migrations should be safe to re-run

## Environment Variables

Common patterns across projects:
- `DEV_SKIP_AUTH=true` - Bypass authentication in development
- `RAILS_MASTER_KEY` - Rails credentials encryption
- `*_CLIENT_ID` / `*_CLIENT_SECRET` - API credentials
- `SENTRY_DSN` - Error tracking
- `AWS_*` - S3/AWS configuration
