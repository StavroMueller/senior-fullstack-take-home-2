defmodule Backend.Journal.Queries.ListJourneys do
  @moduledoc "Reads every journey with its encounters and entries, the one started most recently first."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.LoadedAssociations

  def run do
    Journey
    |> order_by(desc: :inserted_at, desc: :id)
    |> preload(^LoadedAssociations.journey())
    |> Repo.all()
  end
end
