defmodule Backend.Database.Schema.Correction do
  @moduledoc "One suggested change to one span of an entry, with its explanation and mistake category."

  use Ecto.Schema

  alias Backend.Database.Schema.Entry

  schema "corrections" do
    field :original, :string
    field :fix, :string
    field :explanation, :string

    field :category, Ecto.Enum,
      values: [
        :verb_tense,
        :verb_agreement,
        :gender,
        :adjective_agreement,
        :article,
        :preposition,
        :spelling,
        :word_choice
      ]

    belongs_to :entry, Entry

    timestamps(type: :utc_datetime)
  end
end
