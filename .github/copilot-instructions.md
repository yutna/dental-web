# Copilot Instructions

## Project snapshot

This repository is a Rails 8.1 application on Ruby 4.0.2 and remains close to framework defaults, with a localized homepage at `/:locale` (`/en`, `/th`) plus the Rails health check at `/up`.

Use the repository binstubs (`bin/...`) instead of global commands. CI, setup scripts, and deploy tooling are all wired around those entry points.

## Build, test, and lint commands

| Purpose | Command |
| --- | --- |
| Initial setup | `bin/setup` |
| Non-interactive setup used by CI | `bin/setup --skip-server` |
| Run the app locally | `bin/dev` |
| Prepare the database | `bin/rails db:prepare` |
| Full local verification pass | `bin/ci` |
| Ruby lint | `bin/rubocop` |
| Ruby security scan | `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error` |
| Gem vulnerability scan | `bin/bundler-audit` |
| Importmap package audit | `bin/importmap audit` |
| I18n key health check | `bundle exec i18n-tasks health` |
| Copilot customization asset validation | `ruby script/ci/validate_copilot_assets.rb` |
| Contract guardian CI lane (manual run) | `bash script/ci/contract_guardian` |
| Full test suite | `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"` |
| Single test file | `bin/rspec spec/models/example_spec.rb` |
| Single test at a specific line | `bin/rspec spec/models/example_spec.rb:42` |
| System tests | `bin/rspec spec/system` |
| Run a dedicated Solid Queue worker | `bin/jobs` |
| Replant test seeds the same way CI does | `env RAILS_ENV=test bin/rails db:seed:replant` |
| Asset precompile check | `SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile` |
| Production image build | `docker build -t dental_web .` |

## High-level architecture

- **Rails 8 with Hotwire via importmap, not a Node bundler.** The main layout uses `javascript_importmap_tags`, `config/importmap.rb` pins Turbo and Stimulus, and controllers are auto-loaded from `app/javascript/controllers`. Add browser behavior through importmap + Stimulus conventions rather than introducing npm-based build tooling.
- **SQLite is the backing store in every environment.** Development and test use database files under `storage/`. Production splits persistence into separate SQLite databases for the primary app, cache, queue, and cable connections, with schemas tracked in `db/cache_schema.rb`, `db/queue_schema.rb`, and `db/cable_schema.rb`.
- **Background jobs, cache, and Action Cable are database-backed.** Production switches to `solid_queue`, `solid_cache_store`, and `solid_cable`, with runtime settings in `config/queue.yml`, `config/cache.yml`, and `config/cable.yml`.
- **Single-server deployment is the default operating model.** `config/deploy.yml` sets `SOLID_QUEUE_IN_PUMA=true`, and `config/puma.rb` loads the Solid Queue plugin when that variable is present, so jobs run inside the Puma web process unless deployment is later split into dedicated job hosts.
- **Production is container-first.** `Dockerfile` builds the production image, precompiles assets, and starts the app with `bin/thrust ./bin/rails server`. `bin/docker-entrypoint` automatically runs `db:prepare` before that server command. `config/deploy.yml` is the Kamal deployment config for that containerized flow.
- **Persistent disk storage matters.** The Kamal deploy config mounts `/rails/storage`, which is where production SQLite databases and local Active Storage files live. Active Storage stays on local disk by default (`storage/` in development/production and `tmp/storage` in test).
- **The app surface is intentionally minimal right now.** `config/routes.rb` exposes `/up` and locale-scoped homepage routes at `/:locale`. New features usually need coordinated changes across routes, views, localization, and runtime/deployment config rather than extending existing domain code.
- **PWA support is scaffolded but not enabled end-to-end.** Templates exist under `app/views/pwa/`, but the matching routes in `config/routes.rb` and the manifest link in `app/views/layouts/application.html.erb` are still commented out. If a feature depends on installable-app behavior or push handling, those pieces must be enabled together.

## Key conventions

- **`bin/ci` is the canonical verification workflow.** It runs setup, RuboCop, `bundler-audit`, `importmap audit`, Brakeman, `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`, and `db:seed:replant`. If a change affects setup, seeds, or verification, keep that end-to-end command working.
- **`bin/setup` is the canonical local bootstrap.** It installs gems, prepares the database, clears logs and tmp files, and then hands off to `bin/dev` unless `--skip-server` is passed.
- **Tests use RSpec with Rails integration and Factory Bot.** Core setup lives in `spec/rails_helper.rb` with support files under `spec/support/`; prefer the standard `spec/` directory layout and shared helpers over ad-hoc setup.
- **System tests are separate from the default local CI path.** GitHub Actions runs them in a dedicated `system-test` job, while `bin/ci` leaves them commented out as an optional step.
- **BFF contract is front-end owned.** Keep UI-facing payloads canonical in Rails and map backend responses through `app/integrations/backend/mappers`.
- **Runtime is backend-API first.** When backend APIs are available, BFF must call them directly. Use in-process local providers only for deterministic test seams, not runtime feature modes.
- **Custom app layers are root autoload namespaces.** Classes under `app/use_cases/*`, `app/integrations/*`, and `app/queries/*` are resolved from those roots (e.g., `Security::SignIn`, `Backend::ProviderRegistry`, `Workspace::AppointmentRowsQuery`).
- **Authorization is policy-first via Pundit.** Gate admin routes with `admin:access` and workspace routes with `workspace:read`; do not check raw roles in controllers.
- **Advanced UI component contracts are centralized.** Keep baseline behavior and acceptance criteria in `config/ui_component_specs.yml` and keep UI work aligned with those contracts.
- **Rails UI composition should be componentized.** For reusable UI surfaces (toast/modal/drawer/menus), prefer extracted partials and helper/presenter mapping instead of long inline ERB blocks in layouts.
- **Keep ERB declarative.** Put presentation mapping/derivation logic in helpers or presenters, not inline branching-heavy view templates.
- **Overlay stacking must follow semantic layers.** Use `z-app-*` utilities from `app/assets/tailwind/application.css` rather than ad-hoc numeric z-index values.
- **Feature prompts to AI should include contract + policy context.** Include bounded context, canonical request/response shape, policy requirement, mapper expectations, i18n keys, and accessibility checks.
- **Use path-specific instruction files for focused guidance.** Keep domain-specific conventions in `.github/instructions/*.instructions.md` with `applyTo` globs instead of expanding global instructions.
- **Custom agents are first-class for large tasks.** Prefer `.github/agents/*.agent.md` profiles (`bff-implementer`, `contract-guardian`, `release-hardening`) when delegating specialized work.
- **Skills define repeatable workflows.** Reuse `.github/skills/*/SKILL.md` for feature-slice execution and release-readiness checks instead of re-deriving the process in each prompt.
- **Hooks enforce execution safety.** `.github/hooks/safety-guardrails.json` denies destructive shell commands through `script/copilot_hooks/pre_tool_use_guard.rb`.
- **Prompt files are available for IDE workflows.** Reusable templates live in `.github/prompts/*.prompt.md` and should be used for large requirements-to-implementation prompts.
- **Copilot assets are CI-validated.** Keep frontmatter and hook schemas valid; `ruby script/ci/validate_copilot_assets.rb` runs in local and GitHub CI.
- **Defect feedback loop is enforced for bug-labeled PRs.** If PR labels include bug/defect/regression, update at least one guardrail artifact (`.github/instructions`, `.github/skills`, `.github/prompts`, `.github/copilot-instructions.md`, `AGENTS.md`, or `README.md`).
- **Contract mismatch evidence is artifact-backed.** Write JSON reports to `tmp/contract_diffs` and upload them in CI for triage when present.
- **Seeds are expected to be idempotent.** CI explicitly replants seeds in the test environment.
- **Locale is URL-scoped and required for user-facing pages.** Use `/en` and `/th`; unprefixed root redirects to `/en`, and links should preserve `params[:locale]` via `default_url_options`.
- **I18n maintenance uses `i18n-tasks`.** Keep locale files (`config/locales/en.yml`, `config/locales/th.yml`) normalized and free of missing keys with `bundle exec i18n-tasks health`.
- **Browser support is intentionally modern-only.** `ApplicationController` uses `allow_browser versions: :modern`, so UI work can assume modern browser capabilities instead of legacy fallbacks.
- **Importmap changes are part of normal page invalidation.** `ApplicationController` calls `stale_when_importmap_changes`, so front-end additions should go through `config/importmap.rb` and the standard importmap entrypoints rather than ad-hoc script tags.
- **Shared Ruby code can be placed in `lib/` without manual requires.** `config.autoload_lib(ignore: %w[assets tasks])` autoloads most of `lib/`.
- **Use `bin/jobs` only for split-process job execution.** The default single-server deployment runs Solid Queue inside Puma via `SOLID_QUEUE_IN_PUMA=true`; a separate worker process is the exception, not the baseline.
- **There is no JavaScript package manager workflow in this repo.** JavaScript dependencies are tracked through importmap pins, and the relevant dependency audit is `bin/importmap audit`.
- **Workspace-local Copilot browser automation is configured in `.vscode/mcp.json`.** Prefer that shared Playwright MCP server for browser walkthroughs instead of creating one-off browser automation scripts.
