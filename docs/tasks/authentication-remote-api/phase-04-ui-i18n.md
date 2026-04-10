# Phase 04 — UI & i18n Alignment

## Goal

Update the login form and locale files to match the real API contract:
`username` replaces `email` as the login identifier. Add the two new i18n error keys
(`session_expired`, `service_unavailable`). Both English and Thai locales must be
updated in the same commit.

---

## Scenarios covered

- Username field label and input name are correct (`@must`)
- Error messages appear in the correct locale (`@must`)
- Thai locale sign-in form shows correct label (`@must`)
- `bundle exec i18n-tasks health` passes with zero issues (`@must`)

---

## Scope

```
app/views/auth/sessions/new.html.erb   — change email → username input
config/locales/en.yml                  — add/rename auth.sessions keys
config/locales/th.yml                  — add/rename auth.sessions keys
```

No controller or model changes in this phase (done in Phase 02).

---

## Implementation detail

### 1. Login form — `app/views/auth/sessions/new.html.erb`

**Changes:**
- Input `id`, `name`, `type`, `autocomplete` → `username`
- Label `for` attribute and i18n key → `username_label`
- Retain value if error (`@username` instead of `@email`)

```erb
<%# app/views/auth/sessions/new.html.erb %>
<% content_for :title, t("auth.sessions.title") %>

<main class="mx-auto flex min-h-dvh w-full max-w-6xl items-center justify-center px-6 py-10">
  <section class="w-full max-w-lg rounded-3xl border border-app-border-primary bg-app-surface-primary p-8 shadow-sm ring-1 ring-app-border-primary/20">
    <header>
      <h1 class="text-2xl font-semibold text-app-text-primary"><%= t("auth.sessions.heading") %></h1>
      <p class="mt-2 text-sm text-app-text-secondary"><%= t("auth.sessions.description") %></p>
    </header>

    <% if @auth_error.present? %>
      <div class="mt-5 rounded-xl border border-border-semantic-error-primary bg-bg-semantic-error-default px-4 py-3 text-sm text-text-semantic-error-primary" role="alert">
        <%= @auth_error %>
      </div>
    <% end %>

    <%= form_with url: session_path, method: :post, class: "mt-6 space-y-4" do %>
      <div>
        <label for="username" class="block text-sm font-medium text-app-text-secondary"><%= t("auth.sessions.username_label") %></label>
        <input id="username" name="username" type="text" required autocomplete="username" value="<%= @username %>"
               class="form-input mt-1 block w-full border-app-border-primary bg-app-surface-primary text-app-text-primary placeholder:text-app-text-tertiary focus:border-app-brand-primary focus:ring-app-brand-primary">
      </div>

      <div>
        <label for="password" class="block text-sm font-medium text-app-text-secondary"><%= t("auth.sessions.password_label") %></label>
        <input id="password" name="password" type="password" required autocomplete="current-password"
               class="form-input mt-1 block w-full border-app-border-primary bg-app-surface-primary text-app-text-primary placeholder:text-app-text-tertiary focus:border-app-brand-primary focus:ring-app-brand-primary">
      </div>

      <button type="submit" class="inline-flex w-full items-center justify-center rounded-lg bg-app-brand-primary px-4 py-2 text-sm font-medium text-app-brand-inverse transition hover:bg-app-brand-active">
        <%= t("auth.sessions.submit") %>
      </button>
    <% end %>

    <p class="mt-4 text-xs text-app-text-tertiary"><%= t("auth.sessions.demo_hint") %></p>
  </section>
</main>
```

---

### 2. English locale — `config/locales/en.yml` (auth.sessions section)

Changes from current state:
- Remove `email_label` (replaced by `username_label`)
- Add `username_label`
- Update `invalid_credentials` text ("email" → "username")
- Update `demo_hint` for remote provider context
- Add `session_expired`
- Add `service_unavailable`

```yaml
# config/locales/en.yml — auth.sessions section (full replacement)
auth:
  sessions:
    contract_mismatch: 'Contract mismatch: %{message}'
    demo_hint: Use your clinic system username and password to sign in.
    description: Sign in to access the clinical workspace.
    heading: Sign in to continue
    invalid_credentials: Invalid username or password.
    login_required: Please sign in before accessing the clinical workspace.
    not_authorized: You are not authorized to access this section.
    password_label: Password
    session_expired: Your session has expired. Please sign in again.
    service_unavailable: Authentication service is temporarily unavailable. Please try again shortly.
    signed_in: Signed in successfully.
    signed_out: Signed out successfully.
    submit: Sign in
    title: Sign in
    username_label: Username
```

---

### 3. Thai locale — `config/locales/th.yml` (auth.sessions section)

```yaml
# config/locales/th.yml — auth.sessions section (full replacement)
auth:
  sessions:
    contract_mismatch: 'โครงสร้างสัญญาข้อมูลไม่ตรงกัน: %{message}'
    demo_hint: ใช้ชื่อผู้ใช้และรหัสผ่านของระบบคลินิกในการลงชื่อเข้าใช้
    description: ลงชื่อเข้าใช้เพื่อเข้าสู่พื้นที่ทำงานคลินิก
    heading: ลงชื่อเข้าใช้งาน
    invalid_credentials: ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง
    login_required: กรุณาลงชื่อเข้าใช้ก่อนเข้าสู่พื้นที่ทำงานคลินิก
    not_authorized: คุณไม่มีสิทธิ์เข้าถึงส่วนนี้
    password_label: รหัสผ่าน
    session_expired: เซสชันของคุณหมดอายุแล้ว กรุณาลงชื่อเข้าใช้ใหม่
    service_unavailable: ระบบยืนยันตัวตนไม่สามารถใช้งานได้ชั่วคราว กรุณาลองอีกครั้งในอีกสักครู่
    signed_in: ลงชื่อเข้าใช้สำเร็จ
    signed_out: ออกจากระบบสำเร็จ
    submit: ลงชื่อเข้าใช้
    title: ลงชื่อเข้าใช้
    username_label: ชื่อผู้ใช้
```

---

## Risk notes

- `email_label` key is **removed** — if any other view or spec references it, the
  build will fail on `i18n-tasks health`. Search for `email_label` across all views
  and specs before committing.
- `@email` instance variable in the controller was renamed to `@username` — ensure
  the `sessions/new.html.erb` template uses `@username` consistently.
- `demo_hint` changed wording — the existing request spec checks for the old text
  ("Any non-empty credentials can sign in while provider mode is set to local").
  Update that assertion in Phase 05.

---

## Validation gate

```bash
bin/rubocop
bundle exec i18n-tasks health
bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
```

`i18n-tasks health` must report zero missing and zero unused keys.
