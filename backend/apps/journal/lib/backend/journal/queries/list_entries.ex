defmodule Backend.Journal.Queries.ListEntries do
  @moduledoc "Reads every entry, newest first."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry

  def run do
    Entry |> order_by(desc: :inserted_at, desc: :id) |> Repo.all()
  end
end
