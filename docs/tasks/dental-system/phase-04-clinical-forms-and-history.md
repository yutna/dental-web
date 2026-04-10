# Phase 04 - Clinical Forms, Posts, and Cumulative Dental History

## Goal

Implement the dental clinical workspace behavior and full form persistence model:

- 6 dental-specific forms
- 16 shared form integrations
- Clinical post persistence + extracted projections
- Cumulative tooth map and historical timeline
- Allergy/interactions warning flow

## Scenarios covered

- `@must` procedure validation with required tooth/surface/root/piece fields
- `@must` medication usage warning flow
- `@must` locale-aware validation output
- `@should` allergy warning before medication confirmation

## Scope (files/directories)

- `app/domains/dental/clinical/*`
- `app/use_cases/dental/clinical/*`
- `app/queries/dental/clinical/*`
- `app/controllers/dental/clinical/*`
- `app/views/dental/clinical/*`
- `app/helpers/dental/clinical_helper.rb`
- `app/policies/dental/clinical_policy.rb`

## Implementation details carried from specifications

- Persist all dental forms as clinical posts with form type and structured payload.
- Enforce BR-CF validation rules for each form.
- Extract and maintain query-friendly projections for chart/procedure/image/history summaries.
- Build cumulative patient tooth map across visits.
- Dispatch shared forms through integration seams (pharmacy/lab/radiology/refer).

## Risk notes and guard conditions

- Risk: invalid free-form JSON payloads degrade integrity.
  - Guard: typed validators per form type before persistence.
- Risk: inconsistent history when projections are stale.
  - Guard: rebuild on write and provide reconciliation job.

TODO markers to preserve in implementation:

- TODO (P04-DL-001): confirm clinical image storage backend (local disk vs object storage) for regulator retention policy.
- TODO (P04-DL-001): confirm DICOM viewer requirements and acceptable MIME normalization strategy.

## Decision log (phase 04)

| Decision ID | Temporary decision | Scope | Fallback | Exit criteria |
|---|---|---|---|---|
| P04-DL-001 | Clinical images stored on local Active Storage disk with strict MIME/size validation. | `dental-image` form and image record persistence. | Non-supported file type is rejected with validation error. | Object storage + DICOM viewer requirements approved. |
| P04-DL-002 | Clinical post payload validation is schema-first per form type before persistence. | All 22 form entry points. | Invalid payload returns `VALIDATION_ERROR` and no side effects. | Schema governance process published by architecture board. |
| P04-DL-003 | Cumulative tooth history rebuild runs synchronously on write for correctness-first behavior. | chart/procedure history projections. | Reconciliation job repairs drift if projection write fails. | Performance profiling demands async projection path. |

## Tests to add/update in this phase

- Request specs per dental-specific form save path.
- Validation specs for BR-CF conditional requirements.
- Query specs for cumulative tooth map and history summary correctness.
- System specs for chart/procedure/history workflow and allergy warning behavior.
