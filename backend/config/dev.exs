import Config

config :database, Backend.Database.Repo, database: "wayword_dev"

config :api, Backend.ApiWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "d8RkqVq3S6x0m4tK1zGv7bYwJcHn2pLf9AeU5iO0rTsXyQ1WlMjZ6hDgB3NvC7aE"

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20
