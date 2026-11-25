defmodule Backend.Database.Schema.Journey do
  @moduledoc "One generated adventure: the seed that draws its route, its language and level, and the route position the person is at."

  use Ecto.Schema

  import Ecto.Changeset

  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry

  schema "journeys" do
    field :seed, :integer
    field :language, :string
    field :level, :string
    field :current_point_of_interest_index, :integer, default: 0
    field :finished_at, :utc_datetime
    field :current_point_of_interest_scene, :string
    field :intro, :string

    belongs_to :current_encounter, Encounter

    has_many :entries, Entry, preload_order: [desc: :inserted_at, desc: :id]
    has_many :encounters, Encounter, preload_order: [asc: :after_point_of_interest_index]

    timestamps(type: :utc_datetime)
  end

  @doc "Moves the journey to a point of interest with the teacher's scene there, leaving any encounter."
  def arrival_changeset(%__MODULE__{} = journey, point_of_interest_index, scene) do
    change(journey,
      current_encounter_id: nil,
      current_point_of_interest_index: point_of_interest_index,
      current_point_of_interest_scene: scene
    )
  end

  @doc "Stops the journey at an encounter on the road."
  def current_encounter_changeset(%__MODULE__{} = journey, encounter_id),
    do: change(journey, current_encounter_id: encounter_id)

  @doc "Marks the journey finished at the given time."
  def finished_changeset(%__MODULE__{} = journey, finished_at),
    do: change(journey, finished_at: finished_at)
end
