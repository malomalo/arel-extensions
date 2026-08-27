## [9.0.0] - Unreleased

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
