defmodule Backend.MixProject do
  @moduledoc "The Wayword backend: an umbrella of the database, journal, graphql and api apps."

  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      listeners: [Phoenix.CodeReloader],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run apps/database/priv/repo/seeds.exs"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
