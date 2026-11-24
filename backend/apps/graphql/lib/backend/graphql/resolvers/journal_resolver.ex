defmodule Backend.Graphql.Resolvers.JournalResolver do
  @moduledoc "Maps GraphQL arguments to journal commands and queries."

  alias Backend.Journal

  def get_category_trends(_parent, _arguments, _resolution),
    do: {:ok, Journal.get_category_trends()}

  def get_current_journey(_parent, _arguments, _resolution),
    do: {:ok, Journal.get_current_journey()}

  def get_points_of_interest(journey, _arguments, _resolution),
    do: {:ok, Journal.get_points_of_interest(journey)}

  def get_open_encounter(journey, _arguments, _resolution),
    do: {:ok, Journal.get_journey_progress(journey).open_encounter}

  def get_current_point_of_interest_index(journey, _arguments, _resolution),
    do: {:ok, Journal.get_journey_progress(journey).current_point_of_interest_index}

  def get_encounter_prompt(encounter, _arguments, _resolution),
    do: {:ok, Journal.get_encounter_prompt(encounter)}

  def get_entry(_parent, %{id: entry_id}, _resolution), do: {:ok, Journal.get_entry(entry_id)}

  def get_teacher_reaction(entry, _arguments, _resolution),
    do: {:ok, Journal.get_teacher_reaction(entry)}

  def list_entries(_parent, _arguments, _resolution), do: {:ok, Journal.list_entries()}

  def start_journey(_parent, _arguments, _resolution), do: Journal.start_journey()

  def submit_entry(_parent, %{input: input}, _resolution) do
    case Journal.submit_entry(input) do
      {:ok, entry} -> {:ok, entry}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, error_messages(changeset)}
      {:error, reason} -> {:error, Atom.to_string(reason)}
    end
  end

  def travel_on(_parent, %{journey_id: journey_id}, _resolution) do
    case Journal.travel_on(journey_id) do
      {:ok, journey} -> {:ok, journey}
      {:error, reason} -> {:error, Atom.to_string(reason)}
    end
  end

  def get_can_travel_on(journey, _arguments, _resolution),
    do: {:ok, Journal.get_journey_progress(journey).can_travel_on}

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
