# State 05: Workflow Permission Denied

Route and locale context:

- Route: `/[locale]/workspace` or `/[locale]/dental/visits/:id`
- Auth boundary: signed-in but forbidden by Pundit

## Visual direction

- Explicit, respectful forbidden state with next-step guidance.
- Keep minimal shell chrome for orientation and safe navigation out.
- Offer role-appropriate fallback actions.
- Mobile keeps CTA buttons full width for quick recovery.
- Ensure bilingual copy parity (`en`, `th`).

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Dental Workspace                                                        [Profile ▼]      |
|------------------------------------------------------------------------------------------|
| 403 Forbidden                                                                            |
| You do not have permission to transition this visit.                                     |
| Requested action: workflow.transition (visit D14)                                        |
|------------------------------------------------------------------------------------------|
| [Back to queue] [Request access] [View policy scope]                                     |
|------------------------------------------------------------------------------------------|
| Help: Contact HEAD_DENTAL or SYSTEM_ADMIN with ticket ID: DENY-2026-0410-001            |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Back to queue` returns user to safe list context.
- `Request access` opens prefilled support request modal.

Trigger -> transition notes:

- Policy updated and page retried -> target state opens.
- User remains unauthorized -> stay in forbidden state with audit event.
