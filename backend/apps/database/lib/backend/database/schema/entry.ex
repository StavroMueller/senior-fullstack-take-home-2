defmodule Backend.Database.Schema.Entry do
  @moduledoc "One piece of writing the person submits along a journey, with the status of its analysis."

  use Ecto.Schema

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Journey

  schema "entries" do
    field :body, :string
    field :analysis_status, Ecto.Enum, values: [:analyzing, :analyzed, :analysis_failed]

    belongs_to :journey, Journey
    has_many :corrections, Correction

    timestamps(type: :utc_datetime)
  end
end
