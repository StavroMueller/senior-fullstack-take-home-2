defmodule Backend.Journal.Queries.GetDataSource do
  @moduledoc "Builds the Dataloader source that batches journal associations, with corrections in body order and entries newest first."

  import Ecto.Query

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry

  def run, do: Dataloader.Ecto.new(Repo, query: &scope/2)

  defp scope(Correction, _arguments), do: order_by(Correction, asc: :span_start)
  defp scope(Entry, _arguments), do: order_by(Entry, desc: :inserted_at, desc: :id)
  defp scope(queryable, _arguments), do: queryable
end
