defmodule Backend.Journal.Queries.ListJourneys do
  @moduledoc "Reads every journey, the one started most recently first."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey

  def run do
    Journey |> order_by(desc: :inserted_at, desc: :id) |> Repo.all()
  end
end
