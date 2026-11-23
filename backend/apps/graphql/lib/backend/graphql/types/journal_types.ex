defmodule Backend.Graphql.Types.JournalTypes do
  @moduledoc "GraphQL types for journeys, entries and corrections."

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry

  enum :analysis_status, values: Ecto.Enum.values(Entry, :analysis_status)

  enum :correction_category, values: Ecto.Enum.values(Correction, :category)

  object :journey do
    field :id, non_null(:id)
    field :seed, non_null(:integer)
    field :language, non_null(:string)
    field :level, non_null(:string)
  end

  object :entry do
    field :id, non_null(:id)
    field :body, non_null(:string)
    field :analysis_status, non_null(:analysis_status)
    field :inserted_at, non_null(:datetime)
    field :corrections, non_null(list_of(non_null(:correction))), resolve: dataloader(:journal)
  end

  @desc "One suggested change. The span counts Unicode code points in the entry body, end excluded."
  object :correction do
    field :id, non_null(:id)
    field :span_start, non_null(:integer)
    field :span_end, non_null(:integer)
    field :original, non_null(:string)
    field :fix, non_null(:string)
    field :explanation, non_null(:string)
    field :category, non_null(:correction_category)
  end

  input_object :submit_entry_input do
    field :journey_id, non_null(:id)
    field :body, non_null(:string)
  end
end
