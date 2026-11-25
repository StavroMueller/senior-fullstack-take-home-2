defmodule Backend.Journal.MixProject do
  @moduledoc "Mix project for the `journal` app: entries, corrections, journeys and the AI provider."

  use Mix.Project

  def project do
    [
      app: :journal,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Backend.Journal.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:database, in_umbrella: true},
      {:oban, "~> 2.19"},
      {:phoenix_pubsub, "~> 2.1"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"}
    ]
  end
end
