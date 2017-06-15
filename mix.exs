defmodule ExStatsTracker.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_stats_tracker,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    ExStatsTracker is a StatsD client for Elixir
    """
  end

  defp package do
    [
      maintainers: ["Geoffrey Hayes", "Fahim Zahur"],
      licenses: ["BSD 3-Clause"],
      links: %{"GitHub" => "https://github.com/postmates/ex-stats-tracker"}
    ]
  end
end
