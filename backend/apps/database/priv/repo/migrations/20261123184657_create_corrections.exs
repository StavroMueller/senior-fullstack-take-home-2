defmodule Backend.Database.Repo.Migrations.CreateCorrections do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TYPE correction_category AS ENUM (
        'verb_tense',
        'verb_agreement',
        'gender',
        'adjective_agreement',
        'article',
        'preposition',
        'spelling',
        'word_choice'
      )
      """,
      "DROP TYPE correction_category"
    )

    create table(:corrections) do
      add :entry_id, references(:entries, on_delete: :delete_all), null: false
      add :original, :text, null: false
      add :fix, :text, null: false
      add :explanation, :text, null: false
      add :category, :correction_category, null: false

      timestamps()
    end

    create index(:corrections, [:entry_id])
  end
end
