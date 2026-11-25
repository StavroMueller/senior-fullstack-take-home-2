defmodule Backend.Graphql.MixProject do
  @moduledoc "Mix project for the `graphql` app: the Absinthe schema and its resolvers."

  use Mix.Project

  def project do
    [
      app: :graphql,
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
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:journal, in_umbrella: true},
      {:absinthe, "~> 1.7"}
    ]
  end
end
