# ColorWheel

![ColorWheel logo](assets/logo.svg)

An Elixir library for color palette generation and harmonious color schemes.

![CI](https://img.shields.io/github/actions/workflow/status/eiger-code/ex-color-wheel/elixir.yml?branch=main)
![License: MIT](https://img.shields.io/badge/license-MIT-blue)
![Elixir: ~> 1.18](https://img.shields.io/badge/Elixir-~%3E%201.18-4B275F)
![Erlang/OTP: 27](https://img.shields.io/badge/OTP-27-6E4A7E)

- 🔺 **Triadic palettes**: Three colors equally spaced on the color wheel
- 🔲 **Tetradic palettes**: Four colors forming a rectangle on the color wheel
- ↔️ **Complementary palettes**: Two opposite colors for high contrast
- 🌈 **Analogous palettes**: Adjacent colors for harmonious schemes
- 🔱 **Split-complementary palettes**: Base color with adjacent complements
- 🌓 **Monochromatic palettes**: Variations of the same hue
- 🔄 **Color space conversions**: RGB ↔ HSL
- #️⃣ **Hex support**: Hex string ↔ RGB conversions

## Installation

Add `color_wheel` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:color_wheel, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get`.

## Usage

### Color Palette Generation

```elixir
# Rotation-based: three colors equally spaced on the color wheel
ColorWheel.triadic_palette({120, 50, 50})
# => {:ok, [{120.0, 50, 50}, {240.0, 50, 50}, {0.0, 50, 50}]}

# Variation-based: one hue across five saturation/lightness steps
ColorWheel.monochromatic_palette({240, 80, 60})
# => {:ok, [{240.0, 48, 36}, {240.0, 64, 48}, {240.0, 80, 60},
#          {240.0, 96, 72}, {240.0, 100, 84}]}
```

Every palette generator returns `{:ok, colors}`, or `{:error, reason}` when the
input is not a valid HSL tuple, so palette generation never raises.

The conversions below are stricter. `rgb_to_hsl/1`, `hsl_to_rgb/1` and
`rgb_to_hex/1` raise `ArgumentError` for out-of-range values, while
`hex_to_rgb/1` returns `{:error, :invalid_hex_format}` because unparseable hex is
a data error rather than a programming error.

### Color Space Conversions

```elixir
# RGB to HSL (returns a bare tuple)
ColorWheel.rgb_to_hsl({255, 0, 0})
# => {0.0, 100.0, 50.0}

# Hex to RGB (returns an :ok/:error tuple)
ColorWheel.hex_to_rgb("#FF0000")
# => {:ok, {255, 0, 0}}
```

## API Reference

The `ColorWheel` module is the public entry point, and every function is
documented there with tested examples. The remaining palette generators
(`tetradic_palette/1`, `complementary_palette/1`, `analogous_palette/1`,
`split_complementary_palette/1`), the remaining conversions (`hsl_to_rgb/1`,
`rgb_to_hex/1`) and the colour-space helpers live in `ColorWheel.Palettes` and
`ColorWheel.Color`.

Build the docs locally with `mix docs` and open `doc/index.html`.

## Development

```bash
mix deps.get                          # install dependencies
mix test                              # run the test suite
mix format                            # format the code
mix compile --warnings-as-errors      # compile without warnings
mix credo --strict                    # static analysis
mix docs                              # build HTML docs into doc/
```

Continuous integration runs `mix format --check-formatted`,
`mix compile --warnings-as-errors`, `mix test` and `mix credo --strict` on every
pull request, so run those four before opening one.

## Contributing

Contributions are welcome! Run the checks in
[Development](#development) before submitting a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

