# Test Scenarios: Authentication Remote API Integration

---

## Gherkin scenarios

```gherkin
Feature: User authentication via Meditech Auth API
  As a dental clinic user
  I want to sign in with my username and password
  So that I can access the clinical workspace

  Definitions:
    - Session: Rails encrypted cookie containing access_token, refresh_token, csrf_token, principal
    - Access token: Short-lived JWT (15 min TTL) — must be sent as Bearer header to backend
    - Refresh token: Long-lived JWT (7 days) — used to rotate access token before it expires
    - CSRF token: Opaque hex string returned by API — sent back as x-csrf-token header
    - workspace:read: BFF permission injected for any successfully authenticated user

  # ─── HAPPY PATH ───────────────────────────────────────────────────

  @must
  Scenario: Successful login redirects to home page
    Given I am on the sign-in page at /en/session/new
    When I fill in "username" with "admin.s" and "password" with "123"
    And I submit the sign-in form
    Then I am redirected to /en (the home page)
    And a success flash "Signed in successfully." is shown
    And my session contains access_token, refresh_token, and csrf_token
    And my principal has permission "workspace:read"

  @must
  Scenario: Username field label and input name are correct
    Given I am on the sign-in page at /en/session/new
    Then I see a label for "username" (not "email")
    And the input field has name="username" and type="text"

  @must
  Scenario: Signed-in user accessing sign-in page is redirected to home page
    Given I am signed in as "admin.s"
    When I navigate to /en/session/new
    Then I am redirected to /en (the home page)

  @must
  Scenario: Unauthenticated access to home page redirects to sign-in
    Given I am not signed in
    When I navigate to /en
    Then I am redirected to /en/session/new

  @must
  Scenario: Sign out clears session and calls backend logout
    Given I am signed in as "admin.s"
    When I submit DELETE /en/session
    Then I am redirected to /en
    And the flash shows "Signed out successfully."
    And the session is cleared (no access_token, refresh_token, or csrf_token)
    And POST /auth/v1/logout was called with the access_token and csrf_token

  @must
  Scenario: Accessing workspace while not signed in redirects to login
    Given I am not signed in
    When I navigate to /en/workspace
    Then I am redirected to /en/session/new

  @must
  Scenario: Sign-in form is accessible in Thai locale
    Given I am on /th/session/new
    Then I see "ลงชื่อเข้าใช้งาน" in the heading
    And the username label shows in Thai

  # ─── VALIDATION ERRORS ────────────────────────────────────────────

  @must
  Scenario: Login fails with invalid credentials — 401 from API
    Given I am on the sign-in page
    When I fill in "username" with "wrong.user" and "password" with "bad"
    And I submit the sign-in form
    Then I see the error message "Invalid username or password."
    And the response status is 422
    And no session is created
    And the username field retains the submitted value

  @must
  Scenario: Login fails when username is blank (HTML validation)
    Given I am on the sign-in page
    When I submit with an empty username
    Then the browser blocks submission (HTML5 required constraint)
    And no request is sent to the backend

  @must
  Scenario: Login fails when password is blank (HTML validation)
    Given I am on the sign-in page
    When I submit with an empty password
    Then the browser blocks submission (HTML5 required constraint)

  @must
  Scenario: Login fails when backend API is unreachable
    Given the backend API is not reachable (timeout / connection refused)
    When I submit valid credentials
    Then I see the error "Authentication service is temporarily unavailable."
    And the response status is 422
    And no session is created

  @must
  Scenario: Login fails when backend returns unexpected 5xx
    Given the backend API returns HTTP 500
    When I submit valid credentials
    Then I see the error "Authentication service is temporarily unavailable."
    And the response status is 422

  # ─── TOKEN REFRESH ────────────────────────────────────────────────

  @must
  Scenario: Access token is transparently refreshed before it expires
    Given I am signed in with an access_token that expires in 45 seconds
    When I navigate to /en (before_action fires)
    Then Security::RefreshSession is called automatically
    And my session is updated with a new access_token, refresh_token, and csrf_token
    And I see /en normally (no redirect to login)

  @must
  Scenario: Refresh fails with 401 — session expired in Redis
    Given I am signed in but the refresh_token is rejected by the API (Redis session expired)
    When I navigate to any protected page
    Then my session is cleared
    And I am redirected to /en/session/new
    And the flash shows "Your session has expired. Please sign in again."

  @must
  Scenario: Refresh not triggered when token has more than 60 seconds remaining
    Given I am signed in with an access_token expiring in 5 minutes
    When I navigate to /en
    Then no refresh API call is made
    And I see /en normally

  @should
  Scenario: Refresh token missing from session — fallback to re-login
    Given I am signed in but the session is missing the refresh_token
    When before_action runs
    Then the session is cleared
    And I am redirected to /en/session/new
    And the flash shows "Your session has expired. Please sign in again."

  # ─── AUTHORIZATION ────────────────────────────────────────────────

  @must
  Scenario: Any successfully authenticated user gets workspace:read permission
    Given I log in via the remote provider as "admin.s"
    Then Current.principal.allowed?("workspace:read") returns true
    And I can access /en/workspace

  @must
  Scenario: Unauthenticated access to admin routes is blocked
    Given I am not signed in
    When I navigate to /en/admin
    Then I am redirected to /en/session/new

  @should
  Scenario: Authenticated user without admin:access is denied admin route
    Given I am signed in as a user without "admin:access"
    When I navigate to /en/admin
    Then I am redirected to /en with a "not authorized" flash

  # ─── CONTRACT / MAPPER ────────────────────────────────────────────

  @must
  Scenario: Mapper correctly extracts principal from login response
    Given the backend returns a valid login response with access_token, refresh_token, csrf_token
    When SessionSnapshotMapper.from_remote is called
    Then snapshot.principal.email equals "somchai.admin@meditech.hospital"
    And snapshot.principal.username equals "admin.s"
    And snapshot.principal.display_name is non-blank
    And snapshot.access_token is present
    And snapshot.refresh_token is present
    And snapshot.csrf_token is present
    And snapshot.principal has permission "workspace:read"

  @must
  Scenario: Mapper raises ContractMismatchError when access_token is absent
    Given the backend returns a response with no access_token field
    When SessionSnapshotMapper.from_remote is called
    Then Backend::Errors::UnexpectedResponseError is raised

  @must
  Scenario: Mapper raises ContractMismatchError when email is absent
    Given the backend returns a response with no email in user_session
    When SessionSnapshotMapper.from_remote is called
    Then Backend::Errors::UnexpectedResponseError is raised

  # ─── SESSION STORE ────────────────────────────────────────────────

  @must
  Scenario: SessionStore persists and reads csrf_token
    Given a snapshot with csrf_token="abc123"
    When SessionStore.persist! is called
    And SessionStore.read is called
    Then the read snapshot has csrf_token="abc123"

  @must
  Scenario: SessionStore.clear! removes all token fields including csrf_token
    Given a populated session with all token fields
    When SessionStore.clear! is called
    Then session has no backend_access_token, backend_refresh_token, backend_csrf_token, or backend_principal

  # ─── SECURITY ─────────────────────────────────────────────────────

  @must
  Scenario: CSRF token is never rendered in HTML or exposed to JavaScript
    Given I am signed in
    When I view the page source of any page
    Then the csrf_token value is not present in the HTML

  @must
  Scenario: HttpClient sends csrf_token as x-csrf-token header on authenticated requests
    Given I am signed in with csrf_token="secret"
    When an authenticated backend request is made
    Then the HTTP request includes header "x-csrf-token: secret"
    And the HTTP request includes header "Authorization: Bearer <access_token>"

  @should
  Scenario: Session cookie is not accessible via JavaScript (HttpOnly)
    Given the Rails session cookie is set
    Then the Set-Cookie header includes HttpOnly flag

  @should
  Scenario: Sign-in form has no CSRF token leakage via form fields
    Given I am on /en/session/new
    Then no hidden input contains the backend csrf_token

  # ─── LOCALE ───────────────────────────────────────────────────────

  @must
  Scenario: Error messages appear in the correct locale
    Given I am on /th/session/new
    When I submit invalid credentials
    Then I see the error message in Thai

  @should
  Scenario: Sign-out success message appears in Thai locale
    Given I am signed in and browsing under /th
    When I sign out via DELETE /th/session
    Then the flash "ออกจากระบบสำเร็จ" is shown

  # ─── WONT ─────────────────────────────────────────────────────────

  @wont
  Scenario: "Remember me" persistent sessions
    # Explicitly out of scope for this feature

  @wont
  Scenario: Password reset / forgot password flow
    # Not available in the Auth API in current scope

  @wont
  Scenario: OAuth / SSO login
    # Not available in the Auth API in current scope
```

---

## Step 4 — Test scenario mapping

| Scenario | Priority | Request spec | Policy spec | Mapper/Use case spec | System spec |
|---|---|---|---|---|---|
| Successful login → home page | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/sign_in_spec.rb` | `spec/system/authentication_spec.rb` |
| Username input name/type | @must | `spec/requests/auth_sessions_spec.rb` | — | — | `spec/system/authentication_spec.rb` |
| Signed-in → redirect on GET /session/new | @must | `spec/requests/auth_sessions_spec.rb` | — | — | — |
| Unauthenticated → redirect to login on home page | @must | `spec/requests/auth_sessions_spec.rb` | — | — | `spec/system/authentication_spec.rb` |
| Sign out clears session + calls API | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/sign_out_spec.rb` | `spec/system/authentication_spec.rb` |
| Unauthenticated → redirect to login (workspace) | @must | `spec/requests/auth_sessions_spec.rb` | `spec/policies/workspace_policy_spec.rb` | — | `spec/system/authentication_spec.rb` |
| Thai locale sign-in | @must | `spec/requests/auth_sessions_spec.rb` | — | — | — |
| Invalid credentials 401 | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/sign_in_spec.rb` | — |
| Empty username / HTML validation | @must | — (client-side HTML5) | — | — | `spec/system/authentication_spec.rb` |
| API unreachable / 5xx | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/sign_in_spec.rb` | — |
| Transparent token refresh | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/refresh_session_spec.rb` | — |
| Refresh fails 401 → session cleared | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/refresh_session_spec.rb` | — |
| No refresh when token > 60s remaining | @must | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/refresh_session_spec.rb` | — |
| workspace:read injected for all authed users | @must | — | `spec/policies/workspace_policy_spec.rb` | `spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb` | — |
| Admin blocked when unauthenticated | @must | `spec/requests/admin/clinic_services_spec.rb` | `spec/policies/admin/dashboard_policy_spec.rb` | — | — |
| Mapper extracts principal correctly | @must | — | — | `spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb` | — |
| Mapper raises on missing access_token | @must | — | — | `spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb` | — |
| Mapper raises on missing email | @must | — | — | `spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb` | — |
| SessionStore persists csrf_token | @must | — | — | `spec/use_cases/security/session_store_spec.rb` | — |
| SessionStore.clear! removes all tokens | @must | — | — | `spec/use_cases/security/session_store_spec.rb` | — |
| CSRF token not in HTML | @must | `spec/requests/auth_sessions_spec.rb` | — | — | — |
| x-csrf-token header on auth requests | @must | — | — | `spec/integrations/backend/providers/remote/session_provider_spec.rb` | — |
| HttpOnly cookie | @should | `spec/requests/auth_sessions_spec.rb` | — | — | — |
| Error messages in Thai | @must | `spec/requests/auth_sessions_spec.rb` | — | — | — |
| Missing refresh_token → re-login | @should | `spec/requests/auth_sessions_spec.rb` | — | `spec/use_cases/security/refresh_session_spec.rb` | — |

---

## Step 4.5 — Source traceability matrix

| Source item | Category | Scenario covered? | Extraction covered? | Output location |
|---|---|---|---|---|
| `POST /auth/v1/login` request shape (username, password) | API endpoint | ✓ | ✓ Spec C | `Remote::SessionProvider#sign_in` |
| `POST /auth/v1/login` 201 response (access, refresh, csrf tokens) | API response | ✓ | ✓ Spec C | `SessionSnapshotMapper.from_remote` |
| `POST /auth/v1/login` 401 response | API error | ✓ | ✓ Spec C | `Remote::SessionProvider`, `SignIn` |
| `GET /auth/v1/profile` response (JSON:API, user_session fields) | API response | ✓ (mapper) | ✓ Spec B/C | `SessionSnapshotMapper.from_profile` |
| `POST /auth/v1/refresh` request (refresh_token body + auth headers) | API endpoint | ✓ | ✓ Spec C | `Remote::SessionProvider#refresh` |
| `POST /auth/v1/refresh` 200 response (rotated tokens) | API response | ✓ | ✓ Spec C | `RefreshSession` use case |
| `POST /auth/v1/refresh` 400/401 error | API error | ✓ | ✓ Spec C | `RefreshSession` |
| `POST /auth/v1/logout` endpoint (returns empty body / 401 on already-expired) | API endpoint | ✓ | ✓ Spec C | `Remote::SessionProvider#sign_out` |
| JWT payload structure (`user_session` fields) | Data model | ✓ (mapper) | ✓ Spec B | `SessionSnapshotMapper` |
| Token TTLs (900s / 604800s) | NFR | ✓ (refresh threshold) | ✓ Spec G | `RefreshSession`, `SessionSnapshot` |
| Rate limit headers | NFR | — (logged only) | ✓ Spec G | `HttpClient` |
| CSRF token storage and transmission | Security | ✓ | ✓ Spec F/E | `SessionStore`, `HttpClient` |
| `workspace:read` permission injection | Permissions | ✓ | ✓ Spec C | `SessionSnapshotMapper` |
| i18n: `username_label` | i18n | ✓ | ✓ Spec D | `config/locales/en.yml`, `th.yml` |
| i18n: `session_expired` | i18n | ✓ | ✓ Spec D | `config/locales/en.yml`, `th.yml` |
| i18n: `service_unavailable` | i18n | ✓ | ✓ Spec D | `config/locales/en.yml`, `th.yml` |
| Cookie security flags | Security | ✓ (@should) | ✓ Spec G | `config/environments/production.rb` |

All mandatory source items are covered. ✓ Proceed to decomposition.
