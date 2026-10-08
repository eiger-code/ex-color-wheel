defmodule ColorWheel do
  @moduledoc """
  Color palette generation utilities.

  This module provides a unified API for color operations by delegating
  to specialized submodules for better organization and maintainability.

  ## Error handling

  Palette generation returns `{:ok, colors}` or `{:error, reason}` and never
  raises, so it is safe to call with arbitrary input. The color conversions in
  `ColorWheel.Color` are strict instead and raise `ArgumentError` for values
  outside their documented ranges; `ColorWheel.hex_to_rgb/1` returns
  `{:error, :invalid_hex_format}` because unparseable hex is a data error rather
  than a programming error.
  """

  # Re-export types from submodules for backward compatibility
  @type hsl_color :: ColorWheel.Color.hsl_color()
  @type hsl_color_input :: ColorWheel.Color.hsl_color_input()
  @type rgb_color :: ColorWheel.Color.rgb_color()

  # Result types
  @type palette_result :: {:ok, [hsl_color()]} | {:error, String.t()}
  @type hex_parse_result :: {:ok, rgb_color()} | {:error, ColorWheel.Color.hex_parse_error()}

  # ============================================================================
  # Color Palette Generation (delegated to ColorWheel.Palettes)
  # ============================================================================

  @doc """
  Generates a triadic color palette from a base color.

  Triadic colors are three colors equally spaced around the color wheel (120° apart).
  This creates a harmonious color scheme.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}
    - hue: 0-360 degrees
    - saturation: 0-100 percent
    - lightness: 0-100 percent

  ## Returns
  `{:ok, colors}` where `colors` is a list of three HSL color tuples including
  the original color, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.triadic_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {120.0, 50, 50}, {240.0, 50, 50}]}

       iex> ColorWheel.triadic_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {165.0, 70, 60}, {285.0, 70, 60}]}

  ## Error Examples

       iex> ColorWheel.triadic_palette({0, 150, 50})
       {:error, "saturation must be a number between 0 and 100"}

       iex> ColorWheel.triadic_palette({0, 50, -10})
       {:error, "lightness must be a number between 0 and 100"}

       iex> ColorWheel.triadic_palette({"invalid", 50, 50})
       {:error, "hue must be a number"}

  """
  @spec triadic_palette(hsl_color_input()) :: palette_result()
  defdelegate triadic_palette(color), to: ColorWheel.Palettes

  @doc """
  Generates a tetradic color palette from a base color.

  Tetradic colors (also called rectangular colors) are four colors forming
  a rectangle on the color wheel, consisting of two complementary pairs.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}
    - hue: 0-360 degrees
    - saturation: 0-100 percent
    - lightness: 0-100 percent

  ## Returns
  `{:ok, colors}` where `colors` is a list of four HSL color tuples including
  the original color, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.tetradic_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {90.0, 50, 50}, {180.0, 50, 50}, {270.0, 50, 50}]}

       iex> ColorWheel.tetradic_palette({30, 80, 40})
       {:ok, [{30.0, 80, 40}, {120.0, 80, 40}, {210.0, 80, 40}, {300.0, 80, 40}]}

  """
  @spec tetradic_palette(hsl_color_input()) :: palette_result()
  defdelegate tetradic_palette(color), to: ColorWheel.Palettes

  @doc """
  Generates a complementary color palette from a base color.

  Complementary colors are opposite each other on the color wheel (180° apart).
  This creates high contrast and vibrant color schemes.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}

  ## Returns
  `{:ok, colors}` where `colors` is a list of two HSL color tuples: the original
  color and its complement, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.complementary_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {180.0, 50, 50}]}

       iex> ColorWheel.complementary_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {225.0, 70, 60}]}

  ## Error Examples

       iex> ColorWheel.complementary_palette({0, 150, 50})
       {:error, "saturation must be a number between 0 and 100"}

  """
  @spec complementary_palette(hsl_color_input()) :: palette_result()
  defdelegate complementary_palette(color), to: ColorWheel.Palettes

  @doc """
  Generates an analogous color palette from a base color.

  Analogous colors are adjacent to each other on the color wheel (typically 30° apart).
  This creates harmonious and serene color schemes.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}

  ## Returns
  `{:ok, colors}` where `colors` is a list of five HSL color tuples: the original
  color and two colors on each side, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.analogous_palette({0, 50, 50})
       {:ok, [{300.0, 50, 50}, {330.0, 50, 50}, {0.0, 50, 50}, {30.0, 50, 50}, {60.0, 50, 50}]}

       iex> ColorWheel.analogous_palette({120, 70, 60})
       {:ok, [{60.0, 70, 60}, {90.0, 70, 60}, {120.0, 70, 60}, {150.0, 70, 60}, {180.0, 70, 60}]}

  """
  @spec analogous_palette(hsl_color_input()) :: palette_result()
  defdelegate analogous_palette(color), to: ColorWheel.Palettes

  @doc """
  Generates a split-complementary color palette from a base color.

  Split-complementary colors use a base color and two colors adjacent to its complement.
  This provides high contrast like complementary colors but with more variety.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}

  ## Returns
  `{:ok, colors}` where `colors` is a list of three HSL color tuples: the original
  color and two adjacent to its complement, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.split_complementary_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {150.0, 50, 50}, {210.0, 50, 50}]}

       iex> ColorWheel.split_complementary_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {195.0, 70, 60}, {255.0, 70, 60}]}

  """
  @spec split_complementary_palette(hsl_color_input()) :: palette_result()
  defdelegate split_complementary_palette(color), to: ColorWheel.Palettes

  @doc """
  Generates a monochromatic color palette from a base color.

  Monochromatic colors use variations of the same hue with different saturation
  and lightness values. This creates sophisticated and unified color schemes.

  ## Parameters
  - `color`: A tuple representing HSL color {hue, saturation, lightness}

  ## Returns
  `{:ok, colors}` where `colors` is a list of five HSL color tuples with the same
  hue but varying saturation and lightness, or `{:error, reason}`.

  ## Examples

       iex> ColorWheel.monochromatic_palette({120, 50, 50})
       {:ok, [{120.0, 30, 30}, {120.0, 40, 40}, {120.0, 50, 50}, {120.0, 60, 60}, {120.0, 70, 70}]}

       iex> ColorWheel.monochromatic_palette({240, 80, 60})
       {:ok, [{240.0, 48, 36}, {240.0, 64, 48}, {240.0, 80, 60}, {240.0, 96, 72}, {240.0, 100, 84}]}

  ## Edge Cases

   When saturation or lightness values are near the boundaries, the algorithm
   clamps the results to valid ranges:

       iex> ColorWheel.monochromatic_palette({120, 10, 50})
       {:ok, [{120.0, 0, 30}, {120.0, 0, 40}, {120.0, 10, 50}, {120.0, 20, 60}, {120.0, 30, 70}]}

       iex> ColorWheel.monochromatic_palette({120, 50, 5})
       {:ok, [{120.0, 30, 0}, {120.0, 40, 0}, {120.0, 50, 5}, {120.0, 60, 15}, {120.0, 70, 25}]}

  """
  @spec monochromatic_palette(hsl_color_input()) :: palette_result()
  defdelegate monochromatic_palette(color), to: ColorWheel.Palettes

  # ============================================================================
  # Color Space Conversions (delegated to ColorWheel.Color)
  # ============================================================================

  @doc """
  Converts an RGB color to HSL color space.

  ## Parameters
  - `rgb`: A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Returns
  A tuple representing HSL color {hue, saturation, lightness} where:
  - hue: 0-360 degrees
  - saturation: 0-100 percent
  - lightness: 0-100 percent

  ## Examples

       iex> ColorWheel.rgb_to_hsl({255, 0, 0})
       {0.0, 100.0, 50.0}

       iex> ColorWheel.rgb_to_hsl({128, 128, 128})
       {0.0, 0.0, 50.2}

       iex> ColorWheel.rgb_to_hsl({0, 255, 0})
       {120.0, 100.0, 50.0}

       iex> ColorWheel.rgb_to_hsl({0, 0, 255})
       {240.0, 100.0, 50.0}

       iex> ColorWheel.rgb_to_hsl({255, 255, 255})
       {0.0, 0.0, 100.0}

       iex> ColorWheel.rgb_to_hsl({0, 0, 0})
       {0.0, 0.0, 0.0}

  """
  @spec rgb_to_hsl(rgb_color()) :: hsl_color()
  defdelegate rgb_to_hsl(rgb), to: ColorWheel.Color

  @doc """
  Converts an HSL color to RGB color space.

  ## Parameters
  - `hsl`: A tuple representing HSL color {hue, saturation, lightness} where:
    - hue: 0-360 degrees
    - saturation: 0-100 percent
    - lightness: 0-100 percent

  ## Returns
  A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Examples

       iex> ColorWheel.hsl_to_rgb({0.0, 100.0, 50.0})
       {255, 0, 0}

       iex> ColorWheel.hsl_to_rgb({120.0, 100.0, 50.0})
       {0, 255, 0}

       iex> ColorWheel.hsl_to_rgb({240.0, 100.0, 50.0})
       {0, 0, 255}

       iex> ColorWheel.hsl_to_rgb({60.0, 100.0, 50.0})
       {255, 255, 0}

       iex> ColorWheel.hsl_to_rgb({0.0, 0.0, 100.0})
       {255, 255, 255}

       iex> ColorWheel.hsl_to_rgb({0.0, 0.0, 0.0})
       {0, 0, 0}

  """
  @spec hsl_to_rgb(hsl_color_input()) :: rgb_color()
  defdelegate hsl_to_rgb(hsl), to: ColorWheel.Color

  @doc """
  Converts a hex color string to RGB color.

  ## Parameters
  - `hex`: A hex color string in formats "#RRGGBB", "#RGB", "RRGGBB", or "RGB"

  ## Returns
  A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Examples

       iex> ColorWheel.hex_to_rgb("#FF0000")
       {:ok, {255, 0, 0}}

       iex> ColorWheel.hex_to_rgb("#F00")
       {:ok, {255, 0, 0}}

       iex> ColorWheel.hex_to_rgb("3366CC")
       {:ok, {51, 102, 204}}

       iex> ColorWheel.hex_to_rgb("#ABCDEF")
       {:ok, {171, 205, 239}}

  ## Error Examples

       iex> ColorWheel.hex_to_rgb("invalid")
       {:error, :invalid_hex_format}

       iex> ColorWheel.hex_to_rgb("#GGG")
       {:error, :invalid_hex_format}

       iex> ColorWheel.hex_to_rgb("12345")
       {:error, :invalid_hex_format}

       iex> ColorWheel.hex_to_rgb("#12")
       {:error, :invalid_hex_format}

  """
  @spec hex_to_rgb(String.t()) :: hex_parse_result()
  defdelegate hex_to_rgb(hex), to: ColorWheel.Color

  @doc """
  Converts an RGB color to hex color string.

  ## Parameters
  - `rgb`: A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Returns
  A hex color string in format "#RRGGBB"

  ## Examples

      iex> ColorWheel.rgb_to_hex({255, 0, 0})
      "#FF0000"

      iex> ColorWheel.rgb_to_hex({51, 102, 204})
      "#3366CC"

      iex> ColorWheel.rgb_to_hex({0, 0, 0})
      "#000000"

  """
  @spec rgb_to_hex(rgb_color()) :: String.t()
  defdelegate rgb_to_hex(rgb), to: ColorWheel.Color
end
