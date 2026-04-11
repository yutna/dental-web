# State 04: Queue Error Inline

Route and locale context:

- Route: `/[locale]/workspace`
- Auth boundary: signed-in + `workspace:read`

## Visual direction

- Keep table shell visible and show non-blocking inline error banner.
- Show last successful refresh timestamp to preserve trust.
- Primary action is retry; secondary action opens integration details.
- Mobile stacks alert actions below message.
- Use semantic error tokens and readable tone.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace                                                        [Profile ▼]      |
|------------------------------------------------------------------------------------------|
| ! Unable to refresh queue (Registration API timeout). Last data: 09:25                  |
|   [Retry now] [View details]                                                             |
|------------------------------------------------------------------------------------------|
| Q#   Patient           MRN      Service        Dentist      Start   Stage                |
| D12  Somchai Jaidee    HN0008   Scaling        Dr. Mook     09:00   SCRN                |
| D13  Mali Chai         HN0014   Filling        Dr. Narin    09:10   READY               |
|------------------------------------------------------------------------------------------|
| Side context: Integration health -> Registration degraded                                |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Retry now` re-runs queue query in turbo frame.
- `View details` opens error modal with correlation id.

Trigger -> transition notes:

- Retry success -> `state-03-queue-populated`.
- Error persists and auth invalid -> `state-05-workflow-permission-denied`.
