# State 07: Profile Dropdown Open

Route and locale context:

- Route: `/[locale]/workspace` (overlay state, no route change)
- Auth boundary: signed-in

## Visual direction

- Dropdown aligns to top-right profile trigger with clear elevation and boundary.
- First block is compact profile identity summary (name + email + role chip).
- Action groups separated: personalization, language, session action.
- Keep menu width touch-friendly on mobile and pointer-friendly on desktop.
- Open/close animation should be short and optional under reduced motion.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| LOGO                             Clinical Workspace                 [Dr. Narin v]         |
|------------------------------------------------------------------------------------------|
|                                                                            +-----------+ |
|                                                                            | Dr. Narin | |
|                                                                            | narin@... | |
|                                                                            | Dentist   | |
|                                                                            |-----------| |
|                                                                            | Theme     | |
|                                                                            | ( ) Light | |
|                                                                            | (x) Dark  | |
|                                                                            | ( ) System| |
|                                                                            |-----------| |
|                                                                            | Language  | |
|                                                                            | EN | TH   | |
|                                                                            |-----------| |
|                                                                            | Log out   | |
|                                                                            +-----------+ |
| [Underlying dashboard content remains visible but dimmed lightly]                         |
+------------------------------------------------------------------------------------------+
```

Core components and interactions:

- Trigger button: profile avatar/name in top-right.
- Dropdown groups:
  - User snippet (display name, email, role)
  - Theme selector: Light/Dark/System preference
  - Language switcher EN/TH
  - Logout button

Trigger -> transition notes:

- Choose theme -> `state-08-profile-dropdown-theme-language`.
- Choose language -> reload same page with locale path.
- Click logout -> sign-out flow, then sign-in state.
- Escape/outside click -> close menu and return to `state-06`.

Permission/policy constraints:

- Dropdown visible for authenticated users only.
