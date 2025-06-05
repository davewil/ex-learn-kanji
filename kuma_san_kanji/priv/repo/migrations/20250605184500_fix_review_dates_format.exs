defmodule KumaSanKanji.Repo.Migrations.FixReviewDatesFormat do
  use Ecto.Migration

  def change do
    # Set all future dates to yesterday
    execute """
    UPDATE user_kanji_progress
    SET next_review_date = datetime('now', '-1 day')
    WHERE next_review_date > datetime('now')
    """

    # Fix space separator in dates
    execute """
    UPDATE user_kanji_progress
    SET next_review_date = replace(next_review_date, ' ', 'T')
    WHERE next_review_date LIKE '% %'
    """
  end
end
