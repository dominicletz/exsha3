defmodule ExSha3.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_sha3,
      version: "0.1.4",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      package: package(),
      description: "ExSha3 is a pure Elixir implementation of Sha3 and the original Keccak1600-f",
      source_url: "https://github.com/dominicletz/exsha3",
      docs: [
        main: "ExSha3",
        extras: ["README.md"]
      ]
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      maintainers: [
        "Dominic Letz"
      ],
      links: %{
        "GitHub" => "https://github.com/dominicletz/exsha3"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:profiler, "~> 0.2", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: [:dev], runtime: false},
      {:sha3, "2.0.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: [:dev], runtime: false}
    ]
  end
end
