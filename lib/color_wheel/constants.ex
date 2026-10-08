defmodule ColorWheel.Constants do
  @moduledoc false

  # Canonical bounds of the color spaces this library works with.
  #
  # Kept in one place so `ColorWheel.Color` (which enforces the bounds) and
  # `ColorWheel.Palettes` (which validates against them) cannot drift apart.
  # Saturation and lightness are expressed on a 0..100 percent scale, so their
  # maxima double as the percent-to-fraction normalization factor.

  @hue_max 360.0
  @saturation_max 100.0
  @lightness_max 100.0
  @rgb_max 255

  @doc "Maximum hue in degrees (the color wheel wraps around at this value)."
  @spec hue_max() :: float()
  def hue_max, do: @hue_max

  @doc "Maximum saturation on the 0..100 percent scale."
  @spec saturation_max() :: float()
  def saturation_max, do: @saturation_max

  @doc "Maximum lightness on the 0..100 percent scale."
  @spec lightness_max() :: float()
  def lightness_max, do: @lightness_max

  @doc "Maximum value of a single RGB component."
  @spec rgb_max() :: integer()
  def rgb_max, do: @rgb_max
end
