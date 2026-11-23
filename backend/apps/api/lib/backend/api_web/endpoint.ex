defmodule Backend.ApiWeb.Endpoint do
  @moduledoc "The HTTP endpoint and the browser socket: CORS for the frontend, then the router."

  use Phoenix.Endpoint, otp_app: :api

  socket "/socket", Backend.ApiWeb.UserSocket, websocket: true, longpoll: false

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug CORSPlug, origin: &Backend.ApiWeb.Endpoint.allowed_origins/0
  plug Backend.ApiWeb.Router

  def allowed_origins, do: Application.fetch_env!(:api, :allowed_origins)
end
