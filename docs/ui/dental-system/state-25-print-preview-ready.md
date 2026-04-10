# State 25: Print Preview Ready

Route and locale context:

- Route: `/[locale]/dental/print/:visit_id/:type`
- Auth boundary: signed-in + `print:read`

## Visual direction

- Print-first canvas with on-screen controls outside printable area.
- Bilingual header support for EN/TH output parity.
- Include legal-provisional watermark toggle from requirement decision log.
- Mobile preview shows page thumbnails and quick jump.
- Ensure typography remains legible when printed to A4.

## ASCII wireframe

```txt
+------------------------------------------------------------------------------------------+
| Print Preview: Treatment Summary                             [TH/EN] [Print] [Export PDF]|
|------------------------------------------------------------------------------------------|
| Visit D14  Patient HN0045  Date 10 Apr 2026                                               |
|------------------------------------------------------------------------------------------|
| [Printable page area]                                                                     |
|  Dental Treatment Summary / สรุปการรักษาทันตกรรม                                           |
|  Diagnosis: ...                                                                           |
|  Procedures: ...                                                                          |
|  Medications: ...                                                                         |
|  Dentist signature: ____________   Stamp: ____________                                    |
|  Watermark: INTERNAL USE (provisional legal template)                                    |
|------------------------------------------------------------------------------------------|
| Page 1/2 [< Prev] [Next >]                                                                |
+------------------------------------------------------------------------------------------+
```

Core interactions:

- Language toggle switches localized labels while keeping data values.
- Print action opens browser/system print dialogue.

Trigger -> transition notes:

- User without print permission on open -> `state-26-print-forbidden`.
