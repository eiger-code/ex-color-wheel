defmodule ColorWheel.PalettesTest do
  use ExUnit.Case, async: true

  doctest ColorWheel.Palettes

  alias ColorWheel.Palettes

  describe "palette generation" do
    test "triadic_palette generates correct colors" do
      {:ok, result} = Palettes.triadic_palette({0, 50, 50})
      assert length(result) == 3
      assert {0.0, 50, 50} in result
      assert {120.0, 50, 50} in result
      assert {240.0, 50, 50} in result
    end

    test "tetradic_palette generates four colors" do
      {:ok, result} = Palettes.tetradic_palette({0, 50, 50})
      assert length(result) == 4
      assert {0.0, 50, 50} in result
      assert {90.0, 50, 50} in result
      assert {180.0, 50, 50} in result
      assert {270.0, 50, 50} in result
    end

    test "complementary_palette generates two colors" do
      {:ok, result} = Palettes.complementary_palette({0, 50, 50})
      assert length(result) == 2
      assert {0.0, 50, 50} in result
      assert {180.0, 50, 50} in result
    end

    test "analogous_palette generates five colors" do
      {:ok, result} = Palettes.analogous_palette({0, 50, 50})
      assert length(result) == 5
      # Should include the original and adjacent colors
      assert {0.0, 50, 50} in result

      assert result == [
               {300.0, 50, 50},
               {330.0, 50, 50},
               {0.0, 50, 50},
               {30.0, 50, 50},
               {60.0, 50, 50}
             ]
    end

    test "split_complementary_palette generates three colors" do
      {:ok, result} = Palettes.split_complementary_palette({0, 50, 50})
      assert length(result) == 3
      assert {0.0, 50, 50} in result
      assert {150.0, 50, 50} in result
      assert {210.0, 50, 50} in result
    end

    test "monochromatic_palette generates variations" do
      {:ok, result} = Palettes.monochromatic_palette({120, 50, 50})
      assert length(result) == 5
      # All should have the same hue
      assert Enum.all?(result, fn {h, _s, _l} -> h == 120.0 end)
      # Should include the original color
      assert {120.0, 50, 50} in result
    end

    test "monochromatic_palette with low saturation" do
      {:ok, result} = Palettes.monochromatic_palette({120, 10, 50})
      assert length(result) == 5
      # All should have the same hue
      assert Enum.all?(result, fn {h, _s, _l} -> h == 120 end)
      # Saturation should be clamped to minimum 0
      assert Enum.all?(result, fn {_h, s, _l} -> s >= 0 and s <= 100 end)
    end

    test "monochromatic_palette with high saturation" do
      {:ok, result} = Palettes.monochromatic_palette({120, 90, 50})
      assert length(result) == 5
      # All should have the same hue
      assert Enum.all?(result, fn {h, _s, _l} -> h == 120 end)
      # Saturation should be clamped to maximum 100
      assert Enum.all?(result, fn {_h, s, _l} -> s >= 0 and s <= 100 end)
    end

    test "monochromatic_palette with extreme lightness values" do
      {:ok, result} = Palettes.monochromatic_palette({120, 50, 5})
      assert length(result) == 5
      # Lightness should be clamped between 0 and 100
      assert Enum.all?(result, fn {_h, _s, l} -> l >= 0 and l <= 100 end)

      {:ok, result} = Palettes.monochromatic_palette({120, 50, 95})
      assert length(result) == 5
      assert Enum.all?(result, fn {_h, _s, l} -> l >= 0 and l <= 100 end)
    end
  end

  describe "hue normalization" do
    test "hue normalization works" do
      # Test hue > 360 wraps around
      {:ok, result} = Palettes.triadic_palette({400, 50, 50})
      # 400 - 360 = 40
      assert {40.0, 50, 50} in result
    end

    test "hue values are normalized internally" do
      # Test that negative hue values work
      {:ok, result} = Palettes.triadic_palette({-60, 50, 50})
      # -60 + 360 = 300
      assert {300.0, 50, 50} in result
    end

    test "large hue values are normalized" do
      {:ok, result} = Palettes.triadic_palette({720, 50, 50})
      # 720 - 360*2 = 0
      assert {0.0, 50, 50} in result

      {:ok, result} = Palettes.triadic_palette({1080, 50, 50})
      # 1080 - 360*3 = 0
      assert {0.0, 50, 50} in result
    end

    test "very negative hue values are normalized" do
      {:ok, result} = Palettes.triadic_palette({-720, 50, 50})
      # -720 + 360*2 = 0
      assert {0.0, 50, 50} in result
    end
  end

  describe "validation" do
    test "invalid HSL colors return errors" do
      assert {:error, "hue must be a number"} =
               Palettes.triadic_palette({"invalid", 50, 50})

      assert {:error, "saturation must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, 150, 50})

      assert {:error, "saturation must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, -10, 50})

      assert {:error, "lightness must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, 50, -10})

      assert {:error, "lightness must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, 50, 150})

      assert {:error, "saturation must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, "invalid", 50})

      assert {:error, "lightness must be a number between 0 and 100"} =
               Palettes.triadic_palette({0, 50, "invalid"})
    end

    test "non-tuple inputs return errors" do
      assert {:error, "hue must be a number"} = Palettes.triadic_palette("invalid")
      assert {:error, "hue must be a number"} = Palettes.triadic_palette([0, 50, 50])
      assert {:error, "hue must be a number"} = Palettes.triadic_palette({0, 50})
      assert {:error, "hue must be a number"} = Palettes.triadic_palette({0, 50, 50, 100})
    end

    test "float values work correctly" do
      {:ok, result} = Palettes.triadic_palette({0.0, 50.0, 50.0})
      assert length(result) == 3
      assert {0.0, 50.0, 50.0} in result
    end

    test "accepts the open boundaries" do
      assert {:ok, _} = Palettes.triadic_palette({0, 0, 0})
      assert {:ok, _} = Palettes.triadic_palette({360.0, 100.0, 100.0})
      assert {:ok, _} = Palettes.triadic_palette({-360.0, 100, 100})
    end
  end
end
