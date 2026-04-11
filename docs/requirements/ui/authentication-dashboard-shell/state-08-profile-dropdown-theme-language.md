# State 08: Profile Dropdown Theme + Language Feedback

Route and locale context:

- Route: `/[locale]/workspace` (theme toggles in place; locale switch changes route)
- Auth boundary: signed-in

## Visual direction

- Keep dropdown open momentarily after action to confirm selection.
- Show resolved theme indicator for system mode clarity.
- Language action should visibly toggle active chip and then navigate.
- Use semantic token contrast for selected states in both light and dark.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                 [Dr. Narin v]         |
|------------------------------------------------------------------------------------------|
|                                                                            +-----------+ |
|                                                                            | Theme     | |
|                                                                            | ( ) Light | |
|                                                                            | ( ) Dark  | |
|                                                                            | (x) System| |
|                                                                            | Active:   | |
|                                                                            | Dark      | |
|                                                                            |-----------| |
|                                                                            | Language  | |
|                                                                            | EN | [TH] | |
|                                                                            |-----------| |
|                                                                            | Log out   | |
|                                                                            +-----------+ |
| Toast: "Theme preference saved" / "เปลี่ยนภาษาเป็นไทยแล้ว"                               |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Theme radio group with persisted preference.
- Resolved theme label for system mode.
- Language segmented control EN/TH.
- Inline toast/announcement for action confirmation.

Trigger -> transition notes:

- Select `TH` while on `/en/workspace` -> navigate to `/th/workspace` and preserve filters.
- Select theme option -> repaint tokens instantly, remain on same route.

Permission/policy constraints:

- No extra policy; requires active session.
