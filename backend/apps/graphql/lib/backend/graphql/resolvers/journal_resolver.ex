defmodule Backend.Graphql.Resolvers.JournalResolver do
  @moduledoc "Maps GraphQL arguments to journal commands and queries."

  alias Backend.Journal

  def get_current_journey(_parent, _arguments, _resolution),
    do: {:ok, Journal.get_current_journey()}

  def get_entry(_parent, %{id: entry_id}, _resolution), do: {:ok, Journal.get_entry(entry_id)}

  def get_teacher_line(entry, _arguments, _resolution),
    do: {:ok, Journal.get_teacher_line(entry)}

  def list_entries(_parent, _arguments, _resolution), do: {:ok, Journal.list_entries()}

  def start_journey(_parent, _arguments, _resolution), do: Journal.start_journey()

  def submit_entry(_parent, %{input: input}, _resolution) do
    case Journal.submit_entry(input) do
      {:ok, entry} -> {:ok, entry}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, error_messages(changeset)}
    end
  end

  def retry_analysis(_parent, %{entry_id: entry_id}, _resolution) do
    case Journal.retry_analysis(entry_id) do
      {:ok, entry} -> {:ok, entry}
      {:error, reason} -> {:error, Atom.to_string(reason)}
    end
  end

  defp error_messages(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {message, _options} -> message end)
    |> Enum.flat_map(fn {_field, messages} -> messages end)
  end
end
