# Flow 02: Dashboard Shell + Profile Dropdown

## Flow scope

- Signed-in user opens workspace shell.
- User opens top-right profile dropdown and performs theme/language/logout actions.
- Permission-denied branch and data error branch included.

## ASCII flow

```txt
[/[locale]/workspace]
  -> [Policy check workspace:read]
      -> denied -> [Redirect /[locale] + alert] -> [Permission denied state]
      -> allowed -> [Render shell + queue]
          -> [queue loading >300ms] -> [skeleton visible] -> [rows/empty]
          -> [queue fetch error] -> [inline error banner + retry]
          -> [open profile trigger top-right]
              -> [dropdown open]
                  -> [Theme: Light/Dark/System] -> [apply app tokens + persist preference]
                  -> [Language EN/TH] -> [navigate same route with locale]
                  -> [Logout] -> [DELETE /[locale]/session] -> [/[locale]/session/new]
```

## Notes

- Dropdown remains keyboard navigable (Arrow/Tab/Escape) and closes on outside click.
- Theme changes must maintain light/dark parity and semantic token usage.
- Language switch preserves user context when possible (`/en/workspace` <-> `/th/workspace`).
