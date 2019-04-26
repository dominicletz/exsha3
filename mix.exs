defmodule ExSha3.MixProject do
  use Mix.Project

  def project do
    [
      app: :exsha3,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "ExSha3",
      source_url: "https://github.com/dominicletz/exsha3",
      docs: [
        main: "ExSha3",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:sha3, "2.0.0", only: [:dev, :test]},
      {:keccakf1600, "~> 2.0", hex: :keccakf1600_orig, only: [:dev, :test]},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
