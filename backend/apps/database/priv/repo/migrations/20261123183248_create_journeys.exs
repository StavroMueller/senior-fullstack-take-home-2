defmodule Backend.Database.Repo.Migrations.CreateJourneys do
  use Ecto.Migration

  def change do
    create table(:journeys) do
      add :seed, :integer, null: false
      add :language, :string, null: false
      add :level, :string, null: false

      timestamps()
    end
  end
end
