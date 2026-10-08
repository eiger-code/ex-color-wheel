defmodule ColorWheel.Palettes do
  @moduledoc """
  Color palette generation utilities.

  Every generator returns `{:ok, colors}` on success and `{:error, reason}` for
  input that is not a valid HSL tuple, so generating a palette never raises.
  Hue is normalized internally, which means out-of-range hues (including
  negative ones) are accepted.
  """

  alias ColorWheel.Color
  alias ColorWheel.Constants

  # Import types from ColorWheel.Color
  @type hsl_color :: Color.hsl_color()

  # Result types
  @type palette_result :: {:ok, [hsl_color()]} | {:error, String.t()}
  @type validation_result :: :ok | {:error, String.t()}

  # Color wheel angle constants (in degrees)
  @triadic_angles [0, 120, 240]
  @tetradic_angles [0, 90, 180, 270]
  @complementary_angles [0, 180]
  @analogous_angles [-60, -30, 0, 30, 60]
  @split_complementary_angles [0, 150, 210]

  # Monochromatic palette constants
  @saturation_variation_ratio 0.2
  @lightness_variation_ratio 0.2
  @min_step 10

  # Validation bounds come from the shared percent maxima, truncated to whole
  # numbers because they are reported as whole percentages in error messages
  # and used as clamp bounds (where an integer keeps integer inputs integral).
  @saturation_max trunc(Constants.saturation_max())
  @lightness_max trunc(Constants.lightness_max())

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

       iex> ColorWheel.Palettes.triadic_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {120.0, 50, 50}, {240.0, 50, 50}]}

       iex> ColorWheel.Palettes.triadic_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {165.0, 70, 60}, {285.0, 70, 60}]}

  """
  @spec triadic_palette(Color.hsl_color_input()) :: palette_result()
  def triadic_palette(color) do
    case validate_hsl_color(color) do
      :ok -> {:ok, generate_palette(color, @triadic_angles)}
      {:error, reason} -> {:error, reason}
    end
  end

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

      iex> ColorWheel.Palettes.tetradic_palette({0, 50, 50})
      {:ok, [{0.0, 50, 50}, {90.0, 50, 50}, {180.0, 50, 50}, {270.0, 50, 50}]}

      iex> ColorWheel.Palettes.tetradic_palette({30, 80, 40})
      {:ok, [{30.0, 80, 40}, {120.0, 80, 40}, {210.0, 80, 40}, {300.0, 80, 40}]}

  """
  @spec tetradic_palette(Color.hsl_color_input()) :: palette_result()
  def tetradic_palette(color) do
    case validate_hsl_color(color) do
      :ok -> {:ok, generate_palette(color, @tetradic_angles)}
      {:error, reason} -> {:error, reason}
    end
  end

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

       iex> ColorWheel.Palettes.complementary_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {180.0, 50, 50}]}

       iex> ColorWheel.Palettes.complementary_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {225.0, 70, 60}]}

  """
  @spec complementary_palette(Color.hsl_color_input()) :: palette_result()
  def complementary_palette(color) do
    case validate_hsl_color(color) do
      :ok -> {:ok, generate_palette(color, @complementary_angles)}
      {:error, reason} -> {:error, reason}
    end
  end

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

       iex> ColorWheel.Palettes.analogous_palette({0, 50, 50})
       {:ok, [{300.0, 50, 50}, {330.0, 50, 50}, {0.0, 50, 50}, {30.0, 50, 50}, {60.0, 50, 50}]}

       iex> ColorWheel.Palettes.analogous_palette({120, 70, 60})
       {:ok, [{60.0, 70, 60}, {90.0, 70, 60}, {120.0, 70, 60}, {150.0, 70, 60}, {180.0, 70, 60}]}

  """
  @spec analogous_palette(Color.hsl_color_input()) :: palette_result()
  def analogous_palette(color) do
    case validate_hsl_color(color) do
      :ok -> {:ok, generate_palette(color, @analogous_angles)}
      {:error, reason} -> {:error, reason}
    end
  end

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

       iex> ColorWheel.Palettes.split_complementary_palette({0, 50, 50})
       {:ok, [{0.0, 50, 50}, {150.0, 50, 50}, {210.0, 50, 50}]}

       iex> ColorWheel.Palettes.split_complementary_palette({45, 70, 60})
       {:ok, [{45.0, 70, 60}, {195.0, 70, 60}, {255.0, 70, 60}]}

  """
  @spec split_complementary_palette(Color.hsl_color_input()) :: palette_result()
  def split_complementary_palette(color) do
    case validate_hsl_color(color) do
      :ok -> {:ok, generate_palette(color, @split_complementary_angles)}
      {:error, reason} -> {:error, reason}
    end
  end

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

       iex> ColorWheel.Palettes.monochromatic_palette({120, 50, 50})
       {:ok, [{120.0, 30, 30}, {120.0, 40, 40}, {120.0, 50, 50}, {120.0, 60, 60}, {120.0, 70, 70}]}

       iex> ColorWheel.Palettes.monochromatic_palette({240, 80, 60})
       {:ok, [{240.0, 48, 36}, {240.0, 64, 48}, {240.0, 80, 60}, {240.0, 96, 72}, {240.0, 100, 84}]}

  """
  @spec monochromatic_palette(Color.hsl_color_input()) :: palette_result()
  def monochromatic_palette(color) do
    case validate_hsl_color(color) do
      :ok ->
        {hue, saturation, lightness} = color

        base_hue = Color.normalize_hue(hue)
        sat_step = calculate_variation_step(saturation, @saturation_variation_ratio)
        light_step = calculate_variation_step(lightness, @lightness_variation_ratio)

        # Generate variations symmetrically around the base color
        {:ok,
         generate_monochromatic_variations(base_hue, saturation, lightness, sat_step, light_step)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec calculate_variation_step(number(), float()) :: number()
  defp calculate_variation_step(value, ratio) do
    max(@min_step, round(value * ratio))
  end

  @spec generate_monochromatic_variations(float(), number(), number(), number(), number()) :: [
          hsl_color()
        ]
  defp generate_monochromatic_variations(hue, saturation, lightness, sat_step, light_step) do
    # Create 5 variations: 2 darker, 1 base, 2 lighter
    steps = [-2, -1, 0, 1, 2]

    Enum.map(steps, fn step ->
      {
        hue,
        clamp(saturation + step * sat_step, 0, @saturation_max),
        clamp(lightness + step * light_step, 0, @lightness_max)
      }
    end)
  end

  @spec clamp(number(), number(), number()) :: number()
  defp clamp(value, min_val, max_val) do
    value |> max(min_val) |> min(max_val)
  end

  @spec validate_hsl_color(any()) :: validation_result()
  defp validate_hsl_color({hue, saturation, lightness}) do
    validate_hsl_components(hue, saturation, lightness)
  end

  defp validate_hsl_color(_input) do
    {:error, "hue must be a number"}
  end

  @spec validate_hsl_components(any(), any(), any()) :: validation_result()
  defp validate_hsl_components(hue, saturation, lightness) do
    case {validate_hue(hue), validate_saturation(saturation), validate_lightness(lightness)} do
      {:ok, :ok, :ok} -> :ok
      {{:error, _} = error, _, _} -> error
      {_, {:error, _} = error, _} -> error
      {_, _, {:error, _} = error} -> error
    end
  end

  @spec validate_hue(any()) :: validation_result()
  defp validate_hue(hue) when is_number(hue), do: :ok
  defp validate_hue(_hue), do: {:error, "hue must be a number"}

  @spec validate_saturation(any()) :: validation_result()
  defp validate_saturation(saturation)
       when is_number(saturation) and saturation >= 0 and saturation <= @saturation_max,
       do: :ok

  defp validate_saturation(_saturation),
    do: {:error, "saturation must be a number between 0 and #{@saturation_max}"}

  @spec validate_lightness(any()) :: validation_result()
  defp validate_lightness(lightness)
       when is_number(lightness) and lightness >= 0 and lightness <= @lightness_max,
       do: :ok

  defp validate_lightness(_lightness),
    do: {:error, "lightness must be a number between 0 and #{@lightness_max}"}

  @spec generate_palette(Color.hsl_color_input(), [integer()]) :: [hsl_color()]
  defp generate_palette({hue, saturation, lightness}, angles) do
    base_hue = Color.normalize_hue(hue)

    Enum.map(angles, fn angle ->
      {Color.normalize_hue(base_hue + angle), saturation, lightness}
    end)
  end
end
