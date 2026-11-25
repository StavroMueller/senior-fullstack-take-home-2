defmodule Backend.Graphql.Schema do
  @moduledoc "The GraphQL schema the frontend talks to."

  use Absinthe.Schema

  alias Backend.Graphql.Resolvers.JournalResolver

  import_types Absinthe.Type.Custom
  import_types Backend.Graphql.Types.JournalTypes

  query do
    @desc "Answers ok when the API is up."
    field :status, non_null(:string) do
      resolve(fn _parent, _arguments, _resolution -> {:ok, "ok"} end)
    end

    @desc "Each mistake category counted over the analyzed entries, with its trend."
    field :category_trends, non_null(:category_trends) do
      resolve(&JournalResolver.get_category_trends/3)
    end

    @desc "Every journey, the one started most recently first."
    field :journeys, non_null(list_of(non_null(:journey))) do
      resolve(&JournalResolver.list_journeys/3)
    end

    @desc "One journey, or null when no journey has that id."
    field :journey, :journey do
      arg(:id, non_null(:id))
      resolve(&JournalResolver.get_journey/3)
    end

    @desc "Each language and level a journey can start in, with the country its route crosses."
    field :languages, non_null(list_of(non_null(:language))) do
      resolve(&JournalResolver.list_languages/3)
    end

    @desc "One entry, or null when no entry has that id."
    field :entry, :entry do
      arg(:id, non_null(:id))
      resolve(&JournalResolver.get_entry/3)
    end
  end

  mutation do
    @desc "Starts a new journey."
    field :start_journey, non_null(:journey) do
      arg(:language, non_null(:string))
      arg(:level, non_null(:string))
      resolve(&JournalResolver.start_journey/3)
    end

    @desc "Saves one entry as analyzing and starts its analysis."
    field :submit_entry, non_null(:entry) do
      arg(:input, non_null(:submit_entry_input))
      resolve(&JournalResolver.submit_entry/3)
    end

    @desc "Moves the journey on to its next route position, once the current route position has an entry."
    field :travel_on, non_null(:journey) do
      arg(:journey_id, non_null(:id))
      resolve(&JournalResolver.travel_on/3)
    end

    @desc "Runs a failed analysis again."
    field :retry_analysis, non_null(:entry) do
      arg(:entry_id, non_null(:id))
      resolve(&JournalResolver.retry_analysis/3)
    end
  end
end
