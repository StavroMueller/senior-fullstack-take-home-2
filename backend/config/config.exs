import Config

config :database, ecto_repos: [Backend.Database.Repo]

config :database, Backend.Database.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  port: String.to_integer(System.get_env("DATABASE_PORT", "55433")),
  migration_timestamps: [type: :utc_datetime]

config :api, Backend.ApiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  pubsub_server: Backend.Journal.PubSub,
  render_errors: [formats: [json: Backend.ApiWeb.ErrorJSON], layout: false]

config :api, :allowed_origins, ["http://localhost:5173"]

config :api, Oban,
  engine: Oban.Engines.Basic,
  repo: Backend.Database.Repo,
  queues: [analysis: 5]

config :journal, :ai_provider, Backend.Journal.AiProvider.Stub
config :journal, :new_journey, language: "fr", level: "A1"

config :phoenix, :json_library, Jason

config :logger, :console, format: "$time $metadata[$level] $message\n", metadata: [:request_id]

import_config "#{config_env()}.exs"
