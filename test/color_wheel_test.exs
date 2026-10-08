defmodule ColorWheelTest do
  use ExUnit.Case, async: true

  doctest ColorWheel

  alias ColorWheel.Color

  @palette_functions [
    :triadic_palette,
    :tetradic_palette,
    :complementary_palette,
    :analogous_palette,
    :split_complementary_palette,
    :monochromatic_palette
  ]

  @invalid_inputs [
    "invalid",
    nil,
    {0, 50},
    {0, 50, 50, 100},
    [0, 50, 50]
  ]

  describe "palette API" do
    test "every generator returns a tagged tuple" do
      for fun <- @palette_functions do
        assert {:ok, colors} = apply(ColorWheel, fun, [{0, 50, 50}])
        assert is_list(colors)
      end
    end

    test "valid inputs are passed through to ColorWheel.Palettes" do
      for fun <- @palette_functions do
        assert apply(ColorWheel, fun, [{0, 50, 50}]) ==
                 apply(ColorWheel.Palettes, fun, [{0, 50, 50}])
      end
    end

    test "reports the same validation errors as ColorWheel.Palettes" do
      cases = [
        {{"invalid", 50, 50}, "hue must be a number"},
        {{0, 150, 50}, "saturation must be a number between 0 and 100"},
        {{0, -10, 50}, "saturation must be a number between 0 and 100"},
        {{0, 50, -10}, "lightness must be a number between 0 and 100"},
        {{0, 50, 150}, "lightness must be a number between 0 and 100"},
        {{0, "invalid", 50}, "saturation must be a number between 0 and 100"},
        {{0, 50, "invalid"}, "lightness must be a number between 0 and 100"}
      ]

      for fun <- @palette_functions, {input, message} <- cases do
        assert apply(ColorWheel, fun, [input]) == {:error, message}
        assert apply(ColorWheel.Palettes, fun, [input]) == {:error, message}
      end
    end

    test "non-tuple input returns an error instead of raising" do
      for fun <- @palette_functions, input <- @invalid_inputs do
        assert apply(ColorWheel, fun, [input]) == {:error, "hue must be a number"}
      end
    end
  end

  describe "color conversion API" do
    test "delegates each conversion to ColorWheel.Color" do
      assert ColorWheel.rgb_to_hsl({255, 0, 0}) == Color.rgb_to_hsl({255, 0, 0})
      assert ColorWheel.hsl_to_rgb({0.0, 100.0, 50.0}) == Color.hsl_to_rgb({0.0, 100.0, 50.0})
      assert ColorWheel.hex_to_rgb("#FF0000") == Color.hex_to_rgb("#FF0000")
      assert ColorWheel.rgb_to_hex({255, 0, 0}) == Color.rgb_to_hex({255, 0, 0})
    end

    test "propagates the strict conversion contract" do
      assert_raise ArgumentError, ~r/expected an RGB color/, fn ->
        ColorWheel.rgb_to_hsl({300, 0, 0})
      end

      assert_raise ArgumentError, ~r/expected an HSL color/, fn ->
        ColorWheel.hsl_to_rgb({0, 150, 50})
      end
    end
  end

  describe "integration tests" do
    test "full color workflow" do
      # Start with hex color
      {:ok, rgb} = Color.hex_to_rgb("#FF6B35")
      hsl = Color.rgb_to_hsl(rgb)

      # Generate palette
      {:ok, palette} = ColorWheel.analogous_palette(hsl)
      assert length(palette) == 5

      # Convert back to hex
      hex_colors =
        Enum.map(palette, fn hsl_color ->
          rgb_color = Color.hsl_to_rgb(hsl_color)
          Color.rgb_to_hex(rgb_color)
        end)

      assert length(hex_colors) == 5
      assert Enum.all?(hex_colors, &String.starts_with?(&1, "#"))
    end

    test "roundtrip conversion through all formats" do
      original_rgb = {123, 45, 67}

      # RGB -> HSL
      hsl = Color.rgb_to_hsl(original_rgb)

      # HSL -> RGB
      assert Color.hsl_to_rgb(hsl) == original_rgb

      # RGB -> Hex
      hex = Color.rgb_to_hex(original_rgb)

      # Hex -> RGB
      {:ok, ^original_rgb} = Color.hex_to_rgb(hex)

      # Generate palette and verify all conversions work
      {:ok, palette} = ColorWheel.triadic_palette(hsl)
      assert length(palette) == 3

      # Convert palette back to hex
      hex_palette =
        Enum.map(palette, fn hsl_color ->
          rgb = Color.hsl_to_rgb(hsl_color)
          Color.rgb_to_hex(rgb)
        end)

      assert length(hex_palette) == 3
      assert Enum.all?(hex_palette, &String.starts_with?(&1, "#"))
    end
  end
end
