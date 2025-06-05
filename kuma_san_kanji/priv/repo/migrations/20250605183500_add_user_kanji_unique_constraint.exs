defmodule KumaSanKanji.Repo.Migrations.AddUserKanjiUniqueConstraint do
  use Ecto.Migration

  def up do
    # First drop any existing duplicates from the user_kanji_progress table
    execute """
    DELETE FROM user_kanji_progress 
    WHERE id NOT IN (
      SELECT min(id)
      FROM user_kanji_progress
      GROUP BY user_id, kanji_id
    );
    """

    create unique_index(:user_kanji_progress, [:user_id, :kanji_id], name: "unique_user_kanji_progress")
  end

  def down do
    drop index(:user_kanji_progress, [:user_id, :kanji_id], name: "unique_user_kanji_progress")
  end
end
