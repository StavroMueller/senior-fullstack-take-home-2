defmodule Backend.Database.Schema.Entry do
  @moduledoc "One piece of writing the person submits at one point of interest or one encounter, with the status of its analysis."

  use Ecto.Schema

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Journey

  schema "entries" do
    field :body, :string
    field :analysis_status, Ecto.Enum, values: [:analyzing, :analyzed, :analysis_failed]
    field :point_of_interest_index, :integer

    belongs_to :journey, Journey
    belongs_to :encounter, Encounter
    has_many :corrections, Correction

    timestamps(type: :utc_datetime)
  end
end
