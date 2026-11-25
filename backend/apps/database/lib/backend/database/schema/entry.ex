defmodule Backend.Database.Schema.Entry do
  @moduledoc "One piece of writing the person submits at one point of interest or one encounter, with the status of its analysis."

  use Ecto.Schema

  import Ecto.Changeset

  alias Backend.Database.Schema.Correction
  alias Backend.Database.Schema.Encounter
  alias Backend.Database.Schema.Journey

  @longest_body 2_000

  schema "entries" do
    field :body, :string
    field :analysis_status, Ecto.Enum, values: [:analyzing, :analyzed, :analysis_failed]
    field :point_of_interest_index, :integer
    field :teacher_reaction, :string

    belongs_to :journey, Journey
    belongs_to :encounter, Encounter
    has_many :corrections, Correction

    timestamps(type: :utc_datetime)
  end

  @doc "Casts a submitted body and its route position, trims the body and composes it to NFC, and requires it at most 2,000 characters long."
  def submission_changeset(%__MODULE__{} = entry, attributes) do
    entry
    |> cast(attributes, [:body, :point_of_interest_index, :encounter_id])
    |> update_change(:body, &trim_and_compose/1)
    |> validate_required([:body])
    |> validate_length(:body, max: @longest_body)
  end

  @doc "Sets the analysis back to analyzing, for a retry."
  def analyzing_changeset(%__MODULE__{} = entry), do: change(entry, analysis_status: :analyzing)

  @doc "Marks the analysis analyzed, with the teacher's reaction or nil."
  def analyzed_changeset(%__MODULE__{} = entry, teacher_reaction),
    do: change(entry, analysis_status: :analyzed, teacher_reaction: teacher_reaction)

  @doc "Marks the analysis failed and keeps the entry."
  def analysis_failed_changeset(%__MODULE__{} = entry),
    do: change(entry, analysis_status: :analysis_failed)

  defp trim_and_compose(body), do: body |> String.trim() |> :unicode.characters_to_nfc_binary()
end
