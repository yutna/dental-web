# State 08: Screening Form Entry

Route and locale context:

- Route: `/[locale]/dental/visits/:id/clinical?tab=screening`
- Auth boundary: signed-in + `clinical:write`

## Visual direction

- Two-column clinical editor on desktop; single column on mobile.
- Left area for patient context and current stage, right for form sections.
- Inline validation appears under each field with locale-specific copy.
- Sticky save bar ensures continuous flow in long forms.
- Form labels and units are explicit for clinical speed.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Visit D12  HN0008  Somchai J.                              Stage: screening              |
|------------------------------------------------------------------------------------------|
| Tabs: [Screening*] [Treatment] [Medication] [History]                                   |
|------------------------------------------------------------------------------------------|
| Vitals                                                                                   |
| BP [______/______]  Pulse [____] bpm  Temp [____] C  Weight [____] kg                   |
| Height [____] cm   Allergy notes [....................................................] |
|------------------------------------------------------------------------------------------|
| Chief complaint [.....................................................................]  |
| Preliminary findings [.................................................................]  |
|------------------------------------------------------------------------------------------|
| [Save draft] [Save and continue]                                                         |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- `Save and continue` attempts screening -> ready-for-treatment transition.
- Autosave indicator appears after field blur events.

Trigger -> transition notes:

- Missing mandatory vitals on continue -> `state-06-transition-guard-vitals`.
- Success -> `state-09-treatment-form-in-progress`.
