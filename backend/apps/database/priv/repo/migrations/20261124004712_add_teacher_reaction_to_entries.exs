defmodule Backend.Database.Repo.Migrations.AddTeacherReactionToEntries do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :teacher_reaction, :text
    end
  end
end
