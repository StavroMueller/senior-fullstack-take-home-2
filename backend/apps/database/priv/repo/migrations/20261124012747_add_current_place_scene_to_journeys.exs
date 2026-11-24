defmodule Backend.Database.Repo.Migrations.AddCurrentPlaceSceneToJourneys do
  use Ecto.Migration

  def change do
    alter table(:journeys) do
      add :current_place_scene, :text
    end
  end
end
