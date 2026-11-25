defmodule Backend.Graphql.Types.JournalTypes do
  @moduledoc "GraphQL types for journeys, entries and corrections."

  use Absinthe.Schema.Notation

  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Entry
  alias Backend.Graphql.Resolvers.JournalResolver
  alias Backend.Journal.CategoryTrends

  enum :analysis_status, values: Ecto.Enum.values(Entry, :analysis_status)

  enum :correction_category, values: Ecto.Enum.values(Correction, :category)

  @desc "How often a mistake category shows up in the recent half of the analyzed entries, against the older half."
  enum :category_trend_direction, values: CategoryTrends.trends()

  @desc "Each mistake category counted over the analyzed entries, most frequent first."
  object :category_trends do
    field :older_entry_count, non_null(:integer)
    field :recent_entry_count, non_null(:integer)
    field :categories, non_null(list_of(non_null(:category_trend)))
  end

  object :category_trend do
    field :category, non_null(:correction_category)
    field :count, non_null(:integer)

    @desc "Null until two entries are analyzed."
    field :trend, :category_trend_direction
  end

  @desc "A language and level a journey can start in."
  object :language do
    @desc "The ISO 639-1 code, such as fr."
    field :code, non_null(:string)
    @desc "The CEFR level, such as A1."
    field :level, non_null(:string)
    @desc "The country the route crosses."
    field :country, non_null(:string)
  end

  object :journey do
    field :id, non_null(:id)
    field :seed, non_null(:integer)
    field :language, non_null(:string)
    field :level, non_null(:string)
    field :inserted_at, non_null(:datetime)

    @desc "The country the route crosses."
    field :country, non_null(:string), resolve: &JournalResolver.get_country/3

    @desc "Every entry written on the journey, newest first."
    field :entries, non_null(list_of(non_null(:entry))), resolve: dataloader(:journal)

    @desc "Each mistake category counted over the journey's analyzed entries, with its trend."
    field :category_trends, non_null(:category_trends),
      resolve: &JournalResolver.get_journey_category_trends/3

    @desc "The real towns on the route, start first."
    field :points_of_interest, non_null(list_of(non_null(:point_of_interest))),
      resolve: &JournalResolver.get_points_of_interest/3

    @desc "The encounters met so far, each placed after one point of interest."
    field :encounters, non_null(list_of(non_null(:encounter))), resolve: dataloader(:journal)

    @desc "The encounter the person is at, or null when they are at a point of interest."
    field :open_encounter, :encounter, resolve: &JournalResolver.get_open_encounter/3

    @desc "What the teacher says as the journey begins, naming its route; null for journeys started before intros existed."
    field :intro, :string

    @desc "What the teacher says at the current route position, to write about; null once the journey is finished."
    field :current_scene, :string, resolve: &JournalResolver.get_current_scene/3

    @desc "Whether the current route position has an entry, so the journey can move on."
    field :can_travel_on, non_null(:boolean), resolve: &JournalResolver.get_can_travel_on/3

    @desc "The index of the point of interest the person is at, or null once the journey is finished."
    field :current_point_of_interest_index, :integer,
      resolve: &JournalResolver.get_current_point_of_interest_index/3
  end

  @desc "One real town on a route."
  object :point_of_interest do
    field :name, non_null(:string)
    field :longitude, non_null(:float)
    field :latitude, non_null(:float)
  end

  @desc "One fantastical encounter on a route, between two points of interest."
  object :encounter do
    field :id, non_null(:id)
    field :after_point_of_interest_index, non_null(:integer)
    field :prompt, non_null(:string), resolve: &JournalResolver.get_encounter_prompt/3
  end

  object :entry do
    field :id, non_null(:id)
    field :body, non_null(:string)
    field :analysis_status, non_null(:analysis_status)
    field :inserted_at, non_null(:datetime)

    @desc "The point of interest the entry was written at, or null for an encounter entry."
    field :point_of_interest_index, :integer

    @desc "The encounter the entry was written at, or null for a point of interest entry."
    field :encounter, :encounter, resolve: dataloader(:journal)

    field :journey, non_null(:journey), resolve: dataloader(:journal)

    @desc "The teacher's reaction to the entry, or null until its analysis finishes."
    field :teacher_reaction, :string, resolve: &JournalResolver.get_teacher_reaction/3

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
