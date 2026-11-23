defmodule Backend.Database.Repo.Migrations.PlaceEntriesOnTheRoute do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :point_of_interest_index, :integer
      add :encounter_id, references(:encounters, on_delete: :delete_all)
    end

    create unique_index(:entries, [:journey_id, :point_of_interest_index])
    create unique_index(:entries, [:encounter_id])

    create constraint(:entries, :written_at_one_place,
             check: "num_nonnulls(point_of_interest_index, encounter_id) = 1"
           )

    create constraint(:entries, :point_of_interest_index_is_nonnegative,
             check: "point_of_interest_index >= 0"
           )
  end
end
