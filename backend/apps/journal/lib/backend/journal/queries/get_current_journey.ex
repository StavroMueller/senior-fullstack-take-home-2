defmodule Backend.Journal.Queries.GetCurrentJourney do
  @moduledoc "Reads the journey started most recently, or nil before the first one."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  def run do
    Journey |> order_by(desc: :inserted_at, desc: :id) |> limit(1) |> Repo.one()
  end
end
