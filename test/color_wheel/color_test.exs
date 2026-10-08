defmodule ColorWheel.ColorTest do
  use ExUnit.Case, async: true

  doctest ColorWheel.Color

  alias ColorWheel.Color

  @invalid_hex_inputs [
    "invalid",
    "#GGG",
    "GGG",
    "12345",
    "1234567",
    "#12",
    "#12345",
    "#GGGGGG",
    "GGGGGG",
    "",
    "#",
    nil,
    123
  ]

  describe "rgb_to_hsl/1" do
    test "with pure red" do
      assert Color.rgb_to_hsl({255, 0, 0}) == {0.0, 100.0, 50.0}
    end

    test "with white" do
      assert Color.rgb_to_hsl({255, 255, 255}) == {0.0, 0.0, 100.0}
    end

    test "with black" do
      assert Color.rgb_to_hsl({0, 0, 0}) == {0.0, 0.0, 0.0}
    end

    test "with grayscale values" do
      assert Color.rgb_to_hsl({128, 128, 128}) == {0.0, 0.0, 50.2}
      assert Color.rgb_to_hsl({64, 64, 64}) == {0.0, 0.0, 25.1}
      assert Color.rgb_to_hsl({192, 192, 192}) == {0.0, 0.0, 75.29}
    end

    test "with primary colors" do
      assert Color.rgb_to_hsl({0, 255, 0}) == {120.0, 100.0, 50.0}
      assert Color.rgb_to_hsl({0, 0, 255}) == {240.0, 100.0, 50.0}
    end

    test "with boundary values" do
      # Test RGB boundaries
      assert Color.rgb_to_hsl({0, 0, 0}) == {0.0, 0.0, 0.0}
      assert Color.rgb_to_hsl({255, 255, 255}) == {0.0, 0.0, 100.0}
      assert Color.rgb_to_hsl({255, 0, 255}) == {300.0, 100.0, 50.0}
    end

    test "raises ArgumentError for out-of-range components" do
      for rgb <- [{300, 0, 0}, {0, -1, 0}, {0, 0, 256}, {255, 255}] do
        assert_raise ArgumentError, ~r/expected an RGB color \{r, g, b\}/, fn ->
          Color.rgb_to_hsl(rgb)
        end
      end
    end

    test "raises ArgumentError for non-integer components" do
      assert_raise ArgumentError, ~r/got: \{255\.0, 0, 0\}/, fn ->
        Color.rgb_to_hsl({255.0, 0, 0})
      end
    end
  end

  describe "hsl_to_rgb/1" do
    test "with boundary values" do
      assert Color.hsl_to_rgb({0.0, 0.0, 0.0}) == {0, 0, 0}
      assert Color.hsl_to_rgb({0.0, 0.0, 100.0}) == {255, 255, 255}
      assert Color.hsl_to_rgb({360.0, 100.0, 50.0}) == {255, 0, 0}
      assert Color.hsl_to_rgb({0.0, 100.0, 50.0}) == {255, 0, 0}
    end

    test "with different hue sectors" do
      # Test each 60-degree sector of the color wheel
      # Red
      assert Color.hsl_to_rgb({0.0, 100.0, 50.0}) == {255, 0, 0}
      # Yellow
      assert Color.hsl_to_rgb({60.0, 100.0, 50.0}) == {255, 255, 0}
      # Green
      assert Color.hsl_to_rgb({120.0, 100.0, 50.0}) == {0, 255, 0}
      # Cyan
      assert Color.hsl_to_rgb({180.0, 100.0, 50.0}) == {0, 255, 255}
      # Blue
      assert Color.hsl_to_rgb({240.0, 100.0, 50.0}) == {0, 0, 255}
      # Magenta
      assert Color.hsl_to_rgb({300.0, 100.0, 50.0}) == {255, 0, 255}
    end

    test "with hue values inside each sector" do
      assert Color.hsl_to_rgb({30.0, 100.0, 50.0}) == {255, 128, 0}
      assert Color.hsl_to_rgb({90.0, 100.0, 50.0}) == {128, 255, 0}
      assert Color.hsl_to_rgb({150.0, 100.0, 50.0}) == {0, 255, 128}
      assert Color.hsl_to_rgb({210.0, 100.0, 50.0}) == {0, 128, 255}
      assert Color.hsl_to_rgb({270.0, 100.0, 50.0}) == {128, 0, 255}
      assert Color.hsl_to_rgb({330.0, 100.0, 50.0}) == {255, 0, 128}
    end

    test "roundtrip" do
      original_rgb = {128, 64, 192}
      hsl = Color.rgb_to_hsl(original_rgb)
      assert Color.hsl_to_rgb(hsl) == original_rgb
    end

    test "roundtrips a deterministic sample of the whole RGB cube" do
      for r <- 0..255//17, g <- 0..255//17, b <- 0..255//17 do
        rgb = {r, g, b}
        assert Color.hsl_to_rgb(Color.rgb_to_hsl(rgb)) == rgb
      end
    end

    test "raises ArgumentError for out-of-range values" do
      for hsl <- [{0, 150, 50}, {0, 50, -10}, {361.0, 50, 50}, {-1.0, 50, 50}] do
        assert_raise ArgumentError, ~r/expected an HSL color \{h, s, l\}/, fn ->
          Color.hsl_to_rgb(hsl)
        end
      end
    end

    test "raises ArgumentError for non-numeric values" do
      assert_raise ArgumentError, ~r/got: "nope"/, fn ->
        Color.hsl_to_rgb("nope")
      end
    end
  end

  describe "normalize_hue/1" do
    test "wraps hues above the maximum" do
      assert Color.normalize_hue(400) == 40.0
      assert Color.normalize_hue(720) == 0.0
      assert Color.normalize_hue(1080) == 0.0
    end

    test "wraps negative hues" do
      assert Color.normalize_hue(-60) == 300.0
      assert Color.normalize_hue(-720) == 0.0
    end

    test "leaves in-range hues untouched and always returns a float" do
      assert Color.normalize_hue(240) == 240.0
      assert is_float(Color.normalize_hue(240))
      assert is_float(Color.normalize_hue(0))
    end
  end

  describe "hex_to_rgb/1" do
    test "with short format" do
      assert Color.hex_to_rgb("#F00") == {:ok, {255, 0, 0}}
      assert Color.hex_to_rgb("F00") == {:ok, {255, 0, 0}}
    end

    test "with full format" do
      assert Color.hex_to_rgb("#FF0000") == {:ok, {255, 0, 0}}
      assert Color.hex_to_rgb("FF0000") == {:ok, {255, 0, 0}}
    end

    test "with lowercase" do
      assert Color.hex_to_rgb("#ff0000") == {:ok, {255, 0, 0}}
      assert Color.hex_to_rgb("ff0000") == {:ok, {255, 0, 0}}
      assert Color.hex_to_rgb("f00") == {:ok, {255, 0, 0}}
    end

    test "with mixed case" do
      assert Color.hex_to_rgb("#AbCdEf") == {:ok, {171, 205, 239}}
      assert Color.hex_to_rgb("AbCdEf") == {:ok, {171, 205, 239}}
    end

    test "with invalid input" do
      for input <- @invalid_hex_inputs do
        assert Color.hex_to_rgb(input) == {:error, :invalid_hex_format}
      end
    end
  end

  describe "rgb_to_hex/1" do
    test "produces uppercase output" do
      assert Color.rgb_to_hex({255, 0, 0}) == "#FF0000"
      assert Color.rgb_to_hex({171, 205, 239}) == "#ABCDEF"
    end

    test "with boundary values" do
      assert Color.rgb_to_hex({0, 0, 0}) == "#000000"
      assert Color.rgb_to_hex({255, 255, 255}) == "#FFFFFF"
      assert Color.rgb_to_hex({255, 0, 255}) == "#FF00FF"
    end

    test "pads single-digit components" do
      assert Color.rgb_to_hex({1, 2, 3}) == "#010203"
      assert Color.rgb_to_hex({15, 16, 17}) == "#0F1011"
    end

    test "raises ArgumentError for out-of-range components" do
      assert_raise ArgumentError, ~r/expected an RGB color \{r, g, b\}/, fn ->
        Color.rgb_to_hex({300, 0, 0})
      end
    end
  end

  describe "hex/rgb roundtrips" do
    test "hex_rgb roundtrip" do
      original_rgb = {123, 45, 67}
      {:ok, ^original_rgb} = Color.rgb_to_hex(original_rgb) |> Color.hex_to_rgb()
    end

    test "hex_rgb roundtrip with short hex" do
      original_rgb = {255, 0, 0}
      {:ok, ^original_rgb} = Color.rgb_to_hex(original_rgb) |> Color.hex_to_rgb()
    end
  end
end
