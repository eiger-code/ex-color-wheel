defmodule ColorWheel.Color do
  @moduledoc """
  Color space conversion and basic color manipulation utilities.

  Conversions are strict: they accept the canonical ranges `0..360` for hue,
  `0..100` for saturation and lightness, and `0..255` for RGB components, and
  they raise `ArgumentError` for anything else. `ColorWheel.Palettes` is the
  lenient counterpart: it accepts any hue and normalizes it internally.
  """

  alias ColorWheel.Constants

  @type hsl_color :: {hue :: float(), saturation :: number(), lightness :: number()}
  @type rgb_color :: {red :: integer(), green :: integer(), blue :: integer()}
  @type hsl_color_input :: {hue :: number(), saturation :: number(), lightness :: number()}

  # Error types
  @type hex_parse_error :: :invalid_hex_format

  # Color validation constants
  @hue_max Constants.hue_max()
  @saturation_max Constants.saturation_max()
  @lightness_max Constants.lightness_max()
  @rgb_max Constants.rgb_max()

  # Color conversion constants
  @hue_sector_count 6
  @hue_sector_size @hue_max / @hue_sector_count
  @decimal_places 2

  # Hue calculation offsets for different color sectors
  @hue_green_offset 2
  @hue_blue_offset 4

  # Guards
  defguard is_valid_hsl(hsl)
           when is_tuple(hsl) and tuple_size(hsl) == 3 and
                  is_number(elem(hsl, 0)) and elem(hsl, 0) >= 0 and elem(hsl, 0) <= @hue_max and
                  is_number(elem(hsl, 1)) and elem(hsl, 1) >= 0 and
                  elem(hsl, 1) <= @saturation_max and
                  is_number(elem(hsl, 2)) and elem(hsl, 2) >= 0 and elem(hsl, 2) <= @lightness_max

  defguard is_valid_rgb(rgb)
           when is_tuple(rgb) and tuple_size(rgb) == 3 and
                  is_integer(elem(rgb, 0)) and elem(rgb, 0) >= 0 and elem(rgb, 0) <= @rgb_max and
                  is_integer(elem(rgb, 1)) and elem(rgb, 1) >= 0 and elem(rgb, 1) <= @rgb_max and
                  is_integer(elem(rgb, 2)) and elem(rgb, 2) >= 0 and elem(rgb, 2) <= @rgb_max

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

      iex> ColorWheel.Color.rgb_to_hsl({255, 0, 0})
      {0.0, 100.0, 50.0}

      iex> ColorWheel.Color.rgb_to_hsl({128, 128, 128})
      {0.0, 0.0, 50.2}

      iex> ColorWheel.Color.rgb_to_hsl({0, 255, 0})
      {120.0, 100.0, 50.0}

  ## Errors

  Raises `ArgumentError` if `rgb` is not a `{red, green, blue}` tuple of integers
  in `0..255`.

  """
  @spec rgb_to_hsl(rgb_color()) :: hsl_color()
  def rgb_to_hsl(color) when is_valid_rgb(color) do
    {r, g, b} = color
    # Normalize RGB values to 0-1 range
    {r_norm, g_norm, b_norm} = normalize_rgb_values(r, g, b)

    # Calculate HSL components
    {hue, saturation, lightness} = calculate_hsl_components(r_norm, g_norm, b_norm)

    # Round for consistency
    {Float.round(hue, @decimal_places), Float.round(saturation, @decimal_places),
     Float.round(lightness, @decimal_places)}
  end

  def rgb_to_hsl(value), do: invalid_rgb!(value)

  @spec invalid_rgb!(any()) :: no_return()
  defp invalid_rgb!(value) do
    raise ArgumentError,
          "expected an RGB color {r, g, b} with integer components in 0..#{trunc(@rgb_max)}, " <>
            "got: #{inspect(value)}"
  end

  @spec normalize_rgb_values(integer(), integer(), integer()) :: {float(), float(), float()}
  defp normalize_rgb_values(r, g, b) do
    {r / @rgb_max, g / @rgb_max, b / @rgb_max}
  end

  @spec calculate_hsl_components(float(), float(), float()) :: {float(), float(), float()}
  defp calculate_hsl_components(r_norm, g_norm, b_norm) do
    # Find min and max values
    max_val = max(max(r_norm, g_norm), b_norm)
    min_val = min(min(r_norm, g_norm), b_norm)
    delta = max_val - min_val

    lightness = calculate_lightness(max_val, min_val)
    saturation = calculate_saturation(delta, max_val, min_val)
    hue = calculate_hue(delta, max_val, r_norm, g_norm, b_norm)

    {hue, saturation, lightness}
  end

  @spec calculate_lightness(float(), float()) :: float()
  defp calculate_lightness(max_val, min_val),
    do: (max_val + min_val) / 2.0 * @lightness_max

  @spec calculate_saturation(float(), float(), float()) :: float()
  defp calculate_saturation(delta, max_val, min_val) do
    if delta == 0 do
      0.0
    else
      delta / (1 - abs(2 * ((max_val + min_val) / 2) - 1)) * @saturation_max
    end
  end

  @spec calculate_hue(float(), float(), float(), float(), float()) :: float()
  defp calculate_hue(delta, max_val, r_norm, g_norm, b_norm) do
    hue =
      cond do
        delta == 0 ->
          0.0

        max_val == r_norm ->
          @hue_sector_size * :math.fmod((g_norm - b_norm) / delta, @hue_sector_count)

        max_val == g_norm ->
          @hue_sector_size * ((b_norm - r_norm) / delta + @hue_green_offset)

        max_val == b_norm ->
          @hue_sector_size * ((r_norm - g_norm) / delta + @hue_blue_offset)
      end

    # Ensure hue is positive
    normalize_hue(hue)
  end

  @doc """
  Normalizes a hue value into the `0.0..360.0` range by wrapping it around the
  color wheel. The result is always a float.

  ## Examples

      iex> ColorWheel.Color.normalize_hue(400)
      40.0

      iex> ColorWheel.Color.normalize_hue(-60)
      300.0

      iex> ColorWheel.Color.normalize_hue(240)
      240.0

  """
  @spec normalize_hue(number()) :: float()
  def normalize_hue(hue) do
    normalized = :math.fmod(hue, @hue_max)
    if normalized < 0, do: normalized + @hue_max, else: normalized
  end

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

      iex> ColorWheel.Color.hsl_to_rgb({0.0, 100.0, 50.0})
      {255, 0, 0}

      iex> ColorWheel.Color.hsl_to_rgb({120.0, 100.0, 50.0})
      {0, 255, 0}

      iex> ColorWheel.Color.hsl_to_rgb({240.0, 100.0, 50.0})
      {0, 0, 255}

  ## Errors

  Raises `ArgumentError` if `hsl` is not a `{hue, saturation, lightness}` tuple of
  numbers with hue in `0..360` and saturation and lightness in `0..100`.

  """
  @spec hsl_to_rgb(hsl_color_input()) :: rgb_color()
  def hsl_to_rgb(color) when is_valid_hsl(color) do
    {hue, saturation, lightness} = color
    # Normalize values
    {h_norm, s_norm, l_norm} = normalize_hsl_values(hue, saturation, lightness)

    # Calculate intermediate values
    {chroma, x, m} = calculate_rgb_intermediates(h_norm, s_norm, l_norm)

    # Determine RGB values based on hue sector
    {r, g, b} = calculate_rgb_components(h_norm, chroma, x)

    # Convert to 0-255 range and round
    {
      round((r + m) * @rgb_max),
      round((g + m) * @rgb_max),
      round((b + m) * @rgb_max)
    }
  end

  def hsl_to_rgb(value), do: invalid_hsl!(value)

  @spec invalid_hsl!(any()) :: no_return()
  defp invalid_hsl!(value) do
    raise ArgumentError,
          "expected an HSL color {h, s, l} with hue in 0..#{trunc(@hue_max)} and saturation " <>
            "and lightness in 0..#{trunc(@saturation_max)}, got: #{inspect(value)}"
  end

  @spec normalize_hsl_values(number(), number(), number()) :: {float(), float(), float()}
  defp normalize_hsl_values(hue, saturation, lightness) do
    {hue / @hue_max, saturation / @saturation_max, lightness / @lightness_max}
  end

  @spec calculate_rgb_intermediates(float(), float(), float()) :: {float(), float(), float()}
  defp calculate_rgb_intermediates(h_norm, s_norm, l_norm) do
    chroma = (1 - abs(2 * l_norm - 1)) * s_norm
    x = chroma * (1 - abs(:math.fmod(h_norm * @hue_sector_count, 2) - 1))
    m = l_norm - chroma / 2
    {chroma, x, m}
  end

  @spec calculate_rgb_components(float(), float(), float()) :: {float(), float(), float()}
  defp calculate_rgb_components(h_norm, chroma, x) do
    # The color wheel is six 60° sectors; `sector` is the (fractional) sector
    # index, so each whole number is a sector boundary.
    sector = h_norm * @hue_sector_count

    cond do
      sector < 1 -> {chroma, x, 0}
      sector < 2 -> {x, chroma, 0}
      sector < 3 -> {0, chroma, x}
      sector < 4 -> {0, x, chroma}
      sector < 5 -> {x, 0, chroma}
      true -> {chroma, 0, x}
    end
  end

  @doc """
  Converts a hex color string to RGB color.

  ## Parameters
  - `hex`: A hex color string in formats "#RRGGBB", "#RGB", "RRGGBB", or "RGB"

  ## Returns
  A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Examples

      iex> ColorWheel.Color.hex_to_rgb("#FF0000")
      {:ok, {255, 0, 0}}

      iex> ColorWheel.Color.hex_to_rgb("#F00")
      {:ok, {255, 0, 0}}

      iex> ColorWheel.Color.hex_to_rgb("3366CC")
      {:ok, {51, 102, 204}}

      iex> ColorWheel.Color.hex_to_rgb("invalid")
      {:error, :invalid_hex_format}

  """
  @spec hex_to_rgb(String.t()) :: {:ok, rgb_color()} | {:error, hex_parse_error()}
  def hex_to_rgb("#" <> hex), do: hex_to_rgb(hex)

  def hex_to_rgb(hex) when is_binary(hex) do
    case String.length(hex) do
      3 -> parse_short_hex(hex)
      6 -> parse_full_hex(hex)
      _ -> {:error, :invalid_hex_format}
    end
  end

  def hex_to_rgb(_), do: {:error, :invalid_hex_format}

  @spec parse_short_hex(String.t()) :: {:ok, rgb_color()} | {:error, hex_parse_error()}
  defp parse_short_hex(hex) do
    if String.match?(hex, ~r/^[0-9A-Fa-f]{3}$/) do
      # Convert RGB to RRGGBB format
      [r, g, b] = String.graphemes(hex)

      rgb = {
        String.to_integer(r <> r, 16),
        String.to_integer(g <> g, 16),
        String.to_integer(b <> b, 16)
      }

      {:ok, rgb}
    else
      {:error, :invalid_hex_format}
    end
  end

  @spec parse_full_hex(String.t()) :: {:ok, rgb_color()} | {:error, hex_parse_error()}
  defp parse_full_hex(hex) do
    if String.match?(hex, ~r/^[0-9A-Fa-f]{6}$/) do
      # Parse RRGGBB format
      <<r::binary-size(2), g::binary-size(2), b::binary-size(2)>> = hex

      rgb = {
        String.to_integer(r, 16),
        String.to_integer(g, 16),
        String.to_integer(b, 16)
      }

      {:ok, rgb}
    else
      {:error, :invalid_hex_format}
    end
  end

  @doc """
  Converts an RGB color to hex color string.

  ## Parameters
  - `rgb`: A tuple representing RGB color {red, green, blue} where each component is 0-255

  ## Returns
  A hex color string in format "#RRGGBB"

  ## Examples

      iex> ColorWheel.Color.rgb_to_hex({255, 0, 0})
      "#FF0000"

      iex> ColorWheel.Color.rgb_to_hex({51, 102, 204})
      "#3366CC"

      iex> ColorWheel.Color.rgb_to_hex({0, 0, 0})
      "#000000"

  ## Errors

  Raises `ArgumentError` if `rgb` is not a `{red, green, blue}` tuple of integers
  in `0..255`.

  """
  @spec rgb_to_hex(rgb_color()) :: String.t()
  def rgb_to_hex(color) when is_valid_rgb(color) do
    {r, g, b} = color

    # Use uppercase hex digits for consistency
    "#" <> String.upcase(hex_component(r) <> hex_component(g) <> hex_component(b))
  end

  def rgb_to_hex(value), do: invalid_rgb!(value)

  @spec hex_component(integer()) :: String.t()
  defp hex_component(value) do
    value |> Integer.to_string(16) |> String.pad_leading(2, "0")
  end
end
