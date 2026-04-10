# Flow 01: Authentication

## Flow scope

- Entry to sign-in and session creation.
- Failure handling for invalid credentials and contract mismatch.
- Locale-preserving behavior (`/en`, `/th`).

## ASCII flow

```txt
[/[locale]/session/new]
    -> [Enter email + password]
    -> [POST /[locale]/session]
    -> [Validate credentials via Security::SignIn]
        -> success -> [Persist session snapshot] -> [/ [locale]/workspace]
        -> invalid credentials -> [Render sign-in + inline alert] -> [Retry submit]
        -> contract mismatch -> [Render sign-in + integration alert] -> [Retry/Report]

[/[locale]/session/new when signed in]
    -> [Redirect] -> [/ [locale]/workspace]
```

## Notes

- `invalid_credentials` and `contract_mismatch` are distinct UI states and should not be merged.
- Email field value persists after failed submit to reduce re-entry cost.
- No blocking full-page spinner; button-level progress + alert region preferred.
