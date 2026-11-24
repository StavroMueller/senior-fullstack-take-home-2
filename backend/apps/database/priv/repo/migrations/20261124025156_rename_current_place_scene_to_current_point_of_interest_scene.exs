defmodule Backend.Database.Repo.Migrations.RenameCurrentPlaceSceneToCurrentPointOfInterestScene do
  use Ecto.Migration

  def change do
    rename table(:journeys), :current_place_scene, to: :current_point_of_interest_scene
  end
end
