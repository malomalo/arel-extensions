## Unreleased

### Added
- PostgreSQL’s positional range operators on attributes: `ends_before` (`<<`),
  `ends_by` (`&<`), `starts_after` (`>>`), `starts_by` (`&>`) and `adjacent_to`
  (`-|-`). Each compares one edge of the receiver against one edge of the
  operand — `ends_before` is `upper(a) <= lower(b)`, `ends_by` is
  `upper(a) <= upper(b)`, and so on — so the first pair forbid overlap while the
  second pair permit it. Each node is an `InfixOperation`, so Arel’s own visitor
  renders it and no visitor is added here. Operands are quoted through the
  attribute the way `overlaps` quotes them, so a Ruby Range works and an
  already-built node passes through.
- `not_overlaps` on attributes, the negation of Arel core’s `overlaps`. The
  Sunstone visitor already emitted a not_overlaps key but there was no way to
  build the node it visited, so `attribute.not_overlaps(value)` raised
  `NoMethodError`. PostgreSQL has no `!&&` operator, so it is Arel’s own `Not`
  wrapped around `overlaps`, which also means the operand is quoted exactly as
  `overlaps` quotes it.

### Changed
- The Sunstone visitor handles `Arel::Nodes::Not` in place of the
  `Arel::Nodes::NotOverlaps` it used to name. The serialized form is unchanged;
  the node it unwraps is not.

### Fixed
- `contained_by` now accepts a Ruby Range, so range columns work with all three
  range predicates. It was the only one that did not quote its operand — a
  deliberate choice for JSON and ARRAY, whose callers pre-wrap the value — which
  meant `period.contained_by(t1...t2)` raised `TypeError: Cannot visit Range`
  while `contains` and `overlaps` (from Arel core, which quotes through the
  attribute) worked. Only Ruby Ranges are quoted; every other operand is passed
  through untouched as before.

## [9.0.1] - 2026-08-30

### Security
- Fixed a SQL injection in the PostgreSQL visitor's JSON path handling
  ([GHSA-75hc-9q9v-9cv2], CWE-89, high). `key`/`dig` path segments were
  interpolated straight into a `#>'{...}'` array literal, so a segment
  containing `}'` could close the literal and have the rest of it executed as
  SQL. Most reachable through activerecord-filter, where a filter key like
  `"metadata.<payload>"` on a json/jsonb column puts request input into `dig`.
  Segments are now emitted as a quoted `#> array[...]`, which PostgreSQL folds
  back to the same `text[]` constant (existing expression indexes still match).
  Reported by [@saidM](https://github.com/saidM).
- `cast_as` now validates the type name and raises `ArgumentError` unless it
  looks like a type identifier. Not reachable from activerecord-filter, but it
  was the same class of raw interpolation.

### Changed
- A path segment is now always a single segment: `key('a,b')` emits
  `array['a,b']`, where the old raw `'{a,b}'` literal let PostgreSQL split it
  on the comma into two segments. Use `dig('a', 'b')` for multi-segment paths.

[GHSA-75hc-9q9v-9cv2]: https://github.com/malomalo/arel-extensions/security/advisories/GHSA-75hc-9q9v-9cv2

## [9.0.0] - 2026-08-27

### Changed
- Switched to independent Semantic Versioning. Prior releases tracked the Rails
  major/minor line; the version number no longer maps to a Rails version.
- Require Ruby >= 3.3.
- Require ActiveRecord >= 8.0, < 9.0 (dropped support for Rails older than 8.0).

### Added
- `gem.description` and gemspec `metadata` (source, changelog, MFA-required).

### Packaging
- Slimmed the published gem to `lib`, `ext`, `LICENSE`, and `README.md`; removed
  the deprecated `test_files` declaration.

### Documentation
- Documented the features arel-extensions adds (DISTINCT ON, NULLS ordering,
  array/JSON predicates, full-text search, GIS, binary values) in the README.
- Documented that the GIS predicates (`#intersects`, `#within`) require the
  optional `rgeo` gem unless passed an Arel node.

## Earlier releases

Prior versions tracked the matching Rails release. See the Git tags for details:

- [8.1.0] - 2025-12-22
- [8.0.0] - 2025-01-27
- [7.0.1] - 2023-05-31
- [7.0.0] - 2022-12-07
- [6.1.0] - 2021-01-14
- [6.0.0.7] - 2019-11-04
- [6.0.0.2] - 2019-08-12

[9.0.0]: https://github.com/malomalo/arel-extensions/compare/v8.1.0...master
[8.1.0]: https://github.com/malomalo/arel-extensions/releases/tag/v8.1.0
[8.0.0]: https://github.com/malomalo/arel-extensions/releases/tag/v8.0.0
[7.0.1]: https://github.com/malomalo/arel-extensions/releases/tag/v7.0.1
[7.0.0]: https://github.com/malomalo/arel-extensions/releases/tag/v7.0.0
[6.1.0]: https://github.com/malomalo/arel-extensions/releases/tag/v6.1.0
[6.0.0.7]: https://github.com/malomalo/arel-extensions/releases/tag/v6.0.0.7
[6.0.0.2]: https://github.com/malomalo/arel-extensions/releases/tag/v6.0.0.2
