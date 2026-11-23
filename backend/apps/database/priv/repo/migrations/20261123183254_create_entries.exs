defmodule Backend.Database.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE analysis_status AS ENUM ('analyzing', 'analyzed', 'analysis_failed')",
      "DROP TYPE analysis_status"
    )

    create table(:entries) do
      add :journey_id, references(:journeys, on_delete: :delete_all), null: false
      add :body, :text, null: false
      add :analysis_status, :analysis_status, null: false

      timestamps()
    end

    create index(:entries, [:journey_id])
  end
end
