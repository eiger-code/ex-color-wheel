# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-13

### Added

- Square logo mark (`assets/logo-mark.svg`) used by the Hex package and the
  ExDoc sidebar.
- `CHANGELOG.md`, rendered as part of the generated documentation.

### Changed

- Renamed the wide logo asset from `assets/logo.svg` to `assets/logo-full.svg`
  to distinguish it from the new mark, and trimmed its inline annotations.
- Defined the project version once as a `@version` module attribute in `mix.exs`.

### Documentation

- README loads the logo lockup from an absolute GitHub raw URL so that it also
  renders on Hex.pm, and uses it as the page title in place of the previous
  text-only heading.
- Added a Hex.pm version badge to the README.
- ExDoc renders the wheel mark as the documentation logo.

## [0.1.0] - 2026-10-08

Initial public release of ColorWheel.

### Added

- Palette generators, all returning `{:ok, colors}` or `{:error, reason}` for
  invalid input rather than raising:
  - `triadic_palette/1` — three colors equally spaced on the color wheel.
  - `tetradic_palette/1` — four colors forming a rectangle on the color wheel.
  - `complementary_palette/1` — two opposite colors for high contrast.
  - `analogous_palette/1` — adjacent colors for harmonious schemes.
  - `split_complementary_palette/1` — a base color with its adjacent
    complements.
  - `monochromatic_palette/1` — five saturation/lightness variations of one hue.
- Color space conversions:
  - `rgb_to_hsl/1` and `hsl_to_rgb/1` (both returning bare tuples).
  - `hex_to_rgb/1` for 3-, 4-, 6- and 8-digit hex strings, with or without a
    leading `#`.
  - `rgb_to_hex/1` for uppercase `#RRGGBB` output.
  - Hue normalization for out-of-range hue values.
- Strict error contracts: out-of-range RGB/HSL components raise `ArgumentError`,
  while unparseable hex returns `{:error, :invalid_hex_format}`.
- Public modules `ColorWheel`, `ColorWheel.Palettes` and `ColorWheel.Color`,
  documented with tested examples (doctests).
- ExDoc documentation with the README as the main page.
- GitHub Actions CI running `mix format --check-formatted`,
  `mix compile --warnings-as-errors`, `mix test` and `mix credo --strict`.
- MIT license.

[0.2.0]: https://github.com/eiger-code/ex-color-wheel/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/eiger-code/ex-color-wheel/releases/tag/v0.1.0
