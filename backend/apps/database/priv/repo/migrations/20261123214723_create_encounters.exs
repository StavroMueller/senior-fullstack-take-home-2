defmodule Backend.Database.Repo.Migrations.CreateEncounters do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TYPE encounter_kind AS ENUM (
        'sleeping_dragon',
        'talking_goat',
        'giant_snail',
        'ghost_baker',
        'lost_knight',
        'floating_castle',
        'fox_in_a_hat',
        'singing_well'
      )
      """,
      "DROP TYPE encounter_kind"
    )

    create table(:encounters) do
      add :journey_id, references(:journeys, on_delete: :delete_all), null: false
      add :after_point_of_interest_index, :integer, null: false
      add :kind, :encounter_kind, null: false

      timestamps()
    end

    create unique_index(:encounters, [:journey_id, :after_point_of_interest_index])

    create constraint(:encounters, :after_point_of_interest_index_is_nonnegative,
             check: "after_point_of_interest_index >= 0"
           )
  end
end
