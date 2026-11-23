defmodule Backend.Api.MixProject do
  @moduledoc "Mix project for the `api` app: the Phoenix endpoint, GraphQL over HTTP and Oban."

  use Mix.Project

  def project do
    [
      app: :api,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Backend.Api.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_environment), do: ["lib"]

  defp deps do
    [
      {:graphql, in_umbrella: true},
      {:journal, in_umbrella: true},
      {:database, in_umbrella: true},
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.1"},
      {:bandit, "~> 1.5"},
      {:absinthe_plug, "~> 1.5"},
      {:cors_plug, "~> 3.0"},
      {:jason, "~> 1.4"},
      {:oban, "~> 2.19"}
    ]
  end
end
