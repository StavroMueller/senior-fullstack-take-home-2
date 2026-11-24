defmodule Backend.Database.Repo.Migrations.AddNounNumberCategory do
  use Ecto.Migration

  def up do
    execute("ALTER TYPE correction_category ADD VALUE 'noun_number' AFTER 'adjective_agreement'")
  end

  def down do
    execute("""
    DELETE FROM pg_enum
    WHERE enumlabel = 'noun_number' AND enumtypid = 'correction_category'::regtype
    """)
  end
end
