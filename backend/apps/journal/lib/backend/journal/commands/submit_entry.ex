defmodule Backend.Journal.Commands.SubmitEntry do
  @moduledoc "Saves an entry as analyzing and enqueues its analysis in one transaction."

  import Ecto.Changeset

  alias Backend.Database.Repo
  alias Backend.Database.Schema.Entry
  alias Backend.Journal.Jobs.AnalyzeEntry
  alias Ecto.Multi

  @longest_body 2_000

  def execute(%{journey_id: journey_id, body: body}) do
    Multi.new()
    |> Multi.insert(:entry, entry_changeset(journey_id, body))
    |> Oban.insert(:analysis_job, fn %{entry: entry} ->
      AnalyzeEntry.new(%{entry_id: entry.id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{entry: entry}} -> {:ok, entry}
      {:error, :entry, changeset, _changes} -> {:error, changeset}
    end
  end

  defp entry_changeset(journey_id, body) do
    %Entry{analysis_status: :analyzing}
    |> cast(%{journey_id: journey_id, body: normalize(body)}, [:journey_id, :body])
    |> validate_required([:journey_id, :body])
    |> validate_length(:body, max: @longest_body)
    |> assoc_constraint(:journey)
  end

  defp normalize(body), do: body |> String.trim() |> :unicode.characters_to_nfc_binary()
end
