defmodule ColorWheel.MixProject do
  use Mix.Project

  @version "0.3.0"

  def project do
    [
      app: :color_wheel,
      version: @version,
      name: "Color Wheel",
      description: "An Elixir library for color palette generation and harmonious color schemes.",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      package: [
        licenses: ["MIT"],
        # Explicit because Hex's default file list omits `assets`, which ExDoc
        # needs to build the documentation from the package.
        files: ~w(lib assets mix.exs .formatter.exs README.md CHANGELOG.md LICENSE),
        links: %{"GitHub" => "https://github.com/eiger-code/ex-color-wheel"}
      ],
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def deps do
    [
      {:credo, "~> 1.7.19", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  def docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      assets: %{"assets" => "assets"},
      logo: "assets/logo.svg",
      source_url: "https://github.com/eiger-code/ex-color-wheel",
      source_ref: "v#{@version}"
    ]
  end
end
