defmodule Backend.Database.Repo.Migrations.LetAPlaceTakeSeveralEntries do
  use Ecto.Migration

  def change do
    drop unique_index(:entries, [:journey_id, :point_of_interest_index])
    drop unique_index(:entries, [:encounter_id])
    create index(:entries, [:journey_id, :point_of_interest_index])
    create index(:entries, [:encounter_id])

    alter table(:journeys) do
      add :current_point_of_interest_index, :integer, null: false, default: 0
      add :current_encounter_id, references(:encounters, on_delete: :nilify_all)
      add :finished_at, :utc_datetime
    end
  end
end
