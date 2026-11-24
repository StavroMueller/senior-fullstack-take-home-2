defmodule Backend.Database.Schema.Encounter do
  @moduledoc "One fantastical encounter the seed placed on a journey after one point of interest."

  use Ecto.Schema

  alias Backend.Database.Schema.Entry
  alias Backend.Database.Schema.Journey

  schema "encounters" do
    field :after_point_of_interest_index, :integer

    field :kind, Ecto.Enum,
      values: [
        :sleeping_dragon,
        :talking_goat,
        :giant_snail,
        :ghost_baker,
        :lost_knight,
        :floating_castle,
        :fox_in_a_hat,
        :singing_well
      ]

    belongs_to :journey, Journey
    has_many :entries, Entry

    timestamps(type: :utc_datetime)
  end
end
