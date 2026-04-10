# 01 — Overview: Authentication Remote API Integration

## Goal

Wire the existing Rails BFF authentication layer to the real Meditech auth API
(`api-meditech-dev.dudee-indeed.com`) so that:

1. Users log in with `username` + `password` against `POST /auth/v1/login`.
2. After successful login, users are redirected to the home page at `/:locale` (the main page).
3. The home page (`home#index`) requires authentication — unauthenticated visitors are redirected to the sign-in page.
4. Access tokens are transparently refreshed before they expire (15-min TTL).
5. Sign-out calls `POST /auth/v1/logout` to invalidate the server-side Redis session.
6. The CSRF token returned by the API is stored and sent on every subsequent request.
7. All existing workspace and admin authorization boundaries remain intact.
8. Both `/en` and `/th` locale paths work correctly throughout.

---

## Current state summary

| Layer | Status | Gap |
|---|---|---|
| Routes | ✓ Correct | None |
| `Auth::SessionsController` | ✓ Structurally correct | Uses `email:` param name; needs `username:`; redirects to `workspace_path` — change to `root_path` |
| `HomeController` | ✓ Exists | Missing `before_action :require_signed_in!` — home page is currently public |
| `Security::SignIn` | ✓ Orchestration correct | `ensure_workspace_access!` will reject remote users (empty permissions) |
| `Security::SignOut` | ✓ Orchestration correct | Does not call backend logout endpoint |
| `Security::SessionStore` | ✓ Read/persist/clear | Missing `csrf_token` field |
| `Security::SessionSnapshot` | ✓ Domain object | Missing `csrf_token` field |
| `Security::Principal` | ✓ Domain object | Missing `username` field; only `email` |
| `Backend::HttpClient` | Partial | No authenticated requests (GET / auth header POST) |
| `Remote::SessionProvider` | Wrong | Wrong login path + email param; sign_out no-op |
| `SessionSnapshotMapper` | Wrong | Looks for `user.email` wrapper not in real response |
| Login form | Partial | `email` input type/name; needs `username` |
| i18n keys | Partial | Missing: `username_label`, `session_expired`, `service_unavailable` |
| Token refresh | ✗ Missing | Not implemented at all |
| Request specs | Partial | Tests tied to local provider; need remote + refresh coverage |

---

## Phases

| Phase | Name | Key deliverable |
|---|---|---|
| 01 | Foundation — Contracts & Seams | `csrf_token` in snapshot/store; `username` in Principal; `HttpClient` authenticated methods; new `Backend::Errors` |
| 02 | Remote Provider Alignment | Fix login path/params; implement logout; implement refresh; update mapper |
| 03 | Token Refresh & Session Lifecycle | `Security::RefreshSession` use case; `before_action :ensure_fresh_session!` |
| 04 | UI & i18n Alignment | Login form `username` input; i18n key additions/renames (en + th) |
| 05 | Tests & Hardening | Update request specs; add remote integration tests; add system test for full login flow |

---

## Files touched across all phases

```
app/domains/security/
  principal.rb                    (add username field)
  session_snapshot.rb             (add csrf_token field)

app/use_cases/security/
  sign_in.rb                      (update call signature; fix workspace permission logic)
  sign_out.rb                     (no change — delegates to provider)
  session_store.rb                (add csrf_token read/persist/clear)
  refresh_session.rb              (NEW)

app/integrations/backend/
  http_client.rb                  (add get_authenticated, post_authenticated)
  errors.rb                       (add ValidationError, ServiceUnavailableError)
  mappers/session_snapshot_mapper.rb  (update from_remote for real API shape)
  providers/remote/session_provider.rb  (fix login, add logout, add refresh)

app/controllers/
  application_controller.rb       (add ensure_fresh_session! before_action)
  home_controller.rb              (add before_action :require_signed_in!)
  auth/sessions_controller.rb     (username param; redirect to root_path; new error handling for service unavailable)

app/views/auth/sessions/new.html.erb  (email → username input)

config/locales/en.yml             (add/update auth.sessions keys)
config/locales/th.yml             (add/update auth.sessions keys)

spec/requests/auth_sessions_spec.rb      (update + add scenarios)
spec/use_cases/security/
  sign_in_spec.rb                 (NEW)
  refresh_session_spec.rb         (NEW)
spec/integrations/backend/
  mappers/session_snapshot_mapper_spec.rb  (NEW)
  providers/remote/session_provider_spec.rb (NEW)
spec/system/
  authentication_spec.rb          (NEW — end-to-end with real dev API)
```

---

## Validation execution order

Run after every phase commit:

1. `bin/rubocop`
2. `bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"`
3. `bundle exec i18n-tasks health` (phases 04 and 05 only)
4. `bin/ci` as final gate before merging

For the system test phase:

1. `BACKEND_API_BASE_URL=https://your-backend-api bin/rspec spec/system`

---

## Security checklist

- [ ] All session cookies: `secure: true`, `httponly: true`, `same_site: :lax`
- [ ] CSRF token stored in encrypted server-side session (not exposed to client JS)
- [ ] CSRF token sent as `x-csrf-token` header on every authenticated API call
- [ ] Tokens never logged (filter_parameter_logging covers `:access_token`, `:refresh_token`, `:csrf_token`)
- [ ] `HttpClient` connects only to configured `x.backend_api.base_url` (no user-supplied URLs)
- [ ] `ensure_fresh_session!` clears session and redirects on irrecoverable token failure
- [ ] Brakeman scan passes with zero warnings (`bin/brakeman --quiet --no-pager --exit-on-warn`)
- [ ] Rate limit headers are logged but no retry loop that could trigger `ratelimit_remaining: 0`
