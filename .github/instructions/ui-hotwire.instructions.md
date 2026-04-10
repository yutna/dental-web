---
applyTo: "app/views/**/*.erb,app/javascript/**/*.js,app/assets/tailwind/**/*.css,app/assets/stylesheets/**/*.css,config/locales/**/*.yml"
---

# UI and Hotwire instructions

- Treat Rails + Turbo + Stimulus + Tailwind as the default stack; avoid introducing Node-based UI build workflows.
- Keep UI token-driven (`app-*` semantic variables); avoid hardcoded color values in components.
- Ensure light/dark parity for every visual change, including contrast, hover states, and loading states.
- Prefer skeleton and inline progress states over blocking global loaders for async UI.
- Preserve keyboard accessibility: visible focus states, semantic labels, and predictable tab order.
- Keep locale strings in `config/locales/en.yml` and `config/locales/th.yml`; do not inline user-facing strings in templates/controllers.
- For complex UI controls, prefer progressive enhancement with Stimulus and server-safe fallbacks.
- When editing global styles (for example scrollbar/theme), include cross-browser support behavior.
