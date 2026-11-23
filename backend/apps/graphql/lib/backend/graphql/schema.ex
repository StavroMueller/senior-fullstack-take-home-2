defmodule Backend.Graphql.Schema do
  @moduledoc "The GraphQL schema the frontend talks to."

  use Absinthe.Schema

  alias Backend.Graphql.Resolvers.JournalResolver
  alias Backend.Journal

  import_types Absinthe.Type.Custom
  import_types Backend.Graphql.Types.JournalTypes

  query do
    @desc "Answers ok when the API is up."
    field :status, non_null(:string) do
      resolve(fn _parent, _arguments, _resolution -> {:ok, "ok"} end)
    end

    @desc "The journey started most recently, or null before the first one."
    field :current_journey, :journey do
      resolve(&JournalResolver.get_current_journey/3)
    end

    @desc "Every entry, newest first."
    field :entries, non_null(list_of(non_null(:entry))) do
      resolve(&JournalResolver.list_entries/3)
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
      resolve(&JournalResolver.start_journey/3)
    end

    @desc "Saves one entry as analyzing and starts its analysis."
    field :submit_entry, non_null(:entry) do
      arg(:input, non_null(:submit_entry_input))
      resolve(&JournalResolver.submit_entry/3)
    end

    @desc "Runs a failed analysis again."
    field :retry_analysis, non_null(:entry) do
      arg(:entry_id, non_null(:id))
      resolve(&JournalResolver.retry_analysis/3)
    end
  end

  def context(context) do
    loader = Dataloader.add_source(Dataloader.new(), :journal, Journal.get_data_source())
    Map.put(context, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
end
