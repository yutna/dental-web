# State 31: Visit Not Found

Route and locale context:

- Route: `/[locale]/dental/visits/:id`
- Auth boundary: signed-in + `workflow:read`

## Visual direction

- Full-page not-found state within app shell context.
- Keep message precise and include searched visit id.
- Offer recoverable navigation actions only.
- Mobile uses centered compact message card.
- Neutral informational styling.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace                                                        [Profile ▼]      |
|------------------------------------------------------------------------------------------|
| Visit not found                                                                          |
| The requested visit ID D99 does not exist or is no longer available.                     |
|------------------------------------------------------------------------------------------|
| [Back to queue] [Search by HN/VN]                                                        |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Back to queue` returns to list.
- `Search by HN/VN` focuses queue search with carry-over id text.

Trigger -> transition notes:

- Valid visit selected from search -> corresponding visit state opens.
