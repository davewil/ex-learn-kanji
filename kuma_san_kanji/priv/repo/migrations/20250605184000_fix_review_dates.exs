Code.compiler_options(ignore_module_conflict: true)

defmodule KumaSanKanji.Repo.Migrations.FixReviewDates do
  use Ecto.Migration

  def up do
    execute """
    UPDATE user_kanji_progress
    SET next_review_date = strftime('%Y-%m-%d %H:%M:%f', datetime('now', '-1 hour'))
    WHERE next_review_date IS NOT NULL;
    """
  end

  def down do
    # No need to revert this as it's a data fix
  end
end
