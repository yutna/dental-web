# State 01: Queue Loading

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + `workspace:read`

## Visual direction

- Continue existing workspace shell language: sticky top bar, semantic cards, calm contrast.
- Use skeleton rows and skeleton KPI cards when load > 300ms.
- Keep layout stable to avoid content jump.
- Mobile keeps KPI cards as horizontal scroll chips.
- Use `app-*` semantic tokens and respect reduced-motion.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace                              10 Apr 2026                  [Dr. A ▼]     |
|------------------------------------------------------------------------------------------|
| KPI: [████████] [████████] [████████] [████████]                                        |
|------------------------------------------------------------------------------------------|
| Queue today                                                                          [↻] |
| Search [Somchai..............]  Status [All ▼]  Source [All ▼]  [Apply] [Reset]         |
|------------------------------------------------------------------------------------------|
| [██████████████████████████████████████████████████████████████████████████████████]    |
| [██████████████████████████████████████████████████████████████████████████████████]    |
| [██████████████████████████████████████████████████████████████████████████████████]    |
|------------------------------------------------------------------------------------------|
| Side context: loading timeline and payment flags...                                      |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Filter controls are disabled until first payload resolves.
- Skeleton replaced by populated or empty/error state.

Trigger -> transition notes:

- Data arrives with rows -> `state-03-queue-populated`.
- Data arrives empty -> `state-02-queue-empty`.
- Request fails -> `state-04-queue-error-inline`.
