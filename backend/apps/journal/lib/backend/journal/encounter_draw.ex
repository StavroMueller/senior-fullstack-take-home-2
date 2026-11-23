defmodule Backend.Journal.EncounterDraw do
  @moduledoc "Decides from the journey seed whether an encounter follows a point of interest, and which one."

  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Journey
  alias Backend.Journal.Route

  @one_encounter_in 2

  @doc "Returns the kind of encounter after the point of interest, or nil when the road is clear or the route ends there."
  def after_point_of_interest(%Journey{seed: seed}, point_of_interest_index) do
    last_point_of_interest_index = Route.point_of_interest_count() - 1
    encounter_follows? = :erlang.phash2({seed, point_of_interest_index}, @one_encounter_in) == 0

    if point_of_interest_index < last_point_of_interest_index and encounter_follows? do
      kinds = Ecto.Enum.values(Encounter, :kind)
      Enum.at(kinds, :erlang.phash2({seed, point_of_interest_index, :kind}, length(kinds)))
    end
  end
end
