# Agent Operating Guide

This repository uses Rails 8.1 with a BFF-first architecture. Before making changes:

1. Read `.github/copilot-instructions.md`.
2. Read applicable path instructions under `.github/instructions/*.instructions.md`.
3. Preserve canonical BFF contract boundaries and policy-first authorization.

## Quality gates

- Always validate final changes with `bin/ci`.
- For localization updates, run `bundle exec i18n-tasks health`.
- For bug/defect/regression fixes, update a Copilot guardrail artifact to enforce the lesson learned.

## Architectural rules

- Keep controllers thin; place orchestration in use cases.
- Keep provider-specific payload mapping in integration mappers/providers only.
- Keep user-facing paths locale-scoped (`/en`, `/th`) and strings in locale files.

## Copilot customization assets

- Custom agents: `.github/agents/*.agent.md`
- Skills: `.github/skills/*/SKILL.md`
- Hooks: `.github/hooks/safety-guardrails.json`
- Prompt templates (IDE): `.github/prompts/*.prompt.md`
