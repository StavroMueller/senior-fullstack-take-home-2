defmodule Backend.Database.Schema.Journey do
  @moduledoc "One generated adventure: the seed that draws its route, its language and level, and the place the person is at."

  use Ecto.Schema

  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Entry

  schema "journeys" do
    field :seed, :integer
    field :language, :string
    field :level, :string
    field :current_point_of_interest_index, :integer, default: 0
    field :finished_at, :utc_datetime
    field :current_place_scene, :string
    field :intro, :string

    belongs_to :current_encounter, Encounter

    has_many :entries, Entry
    has_many :encounters, Encounter

    timestamps(type: :utc_datetime)
  end
end
