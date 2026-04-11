# Flow 07: Print and Release Readiness

## Flow scope

- Print preview surfaces and policy/legal gating.

## ASCII flow

```txt
[/[locale]/dental/print/:visit_id/:type]
  -> [Policy check print permission]
      -> forbidden -> [Forbidden state + request access CTA]
      -> allowed -> [Bilingual print preview]
          -> legal template provisional flag on
              -> [Internal-use watermark]
          -> user prints/PDF exports
```

## Notes

- Print pages are responsive and print-optimized.
- Legal provisional marker is visible until regulatory signoff.
