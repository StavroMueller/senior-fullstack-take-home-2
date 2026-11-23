defmodule Backend.Database.Repo do
  @moduledoc "The one Ecto repo, on Postgres."

  use Ecto.Repo, otp_app: :database, adapter: Ecto.Adapters.Postgres
end
