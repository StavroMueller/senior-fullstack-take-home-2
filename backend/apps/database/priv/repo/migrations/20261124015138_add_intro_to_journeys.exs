defmodule Backend.Database.Repo.Migrations.AddIntroToJourneys do
  use Ecto.Migration

  def change do
    alter table(:journeys) do
      add :intro, :text
    end
  end
end
