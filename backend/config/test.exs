import Config

config :database, Backend.Database.Repo,
  database: "wayword_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :api, Backend.ApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Q7mN2vB9xK4pL1sD8fG3hJ6kZ0wE5rT2yU9iO4pA7sD1fG6hJ3kL8zX5cV0bN2m",
  server: false

config :api, Oban, testing: :manual

config :logger, level: :warning
