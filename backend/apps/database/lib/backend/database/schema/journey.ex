defmodule Backend.Database.Schema.Journey do
  @moduledoc "One generated adventure: the seed that draws its route, and the language and level it is written in."

  use Ecto.Schema

  alias Backend.Database.Schema.Entry

  schema "journeys" do
    field :seed, :integer
    field :language, :string
    field :level, :string

    has_many :entries, Entry

    timestamps(type: :utc_datetime)
  end
end
