Code.compiler_options(ignore_module_conflict: true)
alias KumaSanKanji.Repo
import Ecto.Query

# Find all duplicates
duplicates_query = """
WITH duplicates AS (
  SELECT k.character, ukp.user_id, COUNT(*) as count
  FROM user_kanji_progress ukp 
  JOIN kanjis k ON k.id = ukp.kanji_id 
  GROUP BY k.character, ukp.user_id
  HAVING COUNT(*) > 1
)
SELECT k.id as kanji_id, k.character, ukp.user_id, ukp.id as progress_id,
       ukp.correct_reviews, ukp.total_reviews, ukp.last_reviewed_at,
       ukp.first_reviewed_at, ukp.last_result, ukp.repetitions,
       ukp.ease_factor, ukp.interval, ukp.next_review_date
FROM duplicates d
JOIN kanjis k ON k.character = d.character
JOIN user_kanji_progress ukp ON ukp.kanji_id = k.id AND ukp.user_id = d.user_id;
"""

results = Repo.query!(duplicates_query)

# Group results by character and user_id
progress_by_char_user =
  results.rows
  |> Enum.group_by(
    fn [_, character, user_id | _] -> {character, user_id} end,
    fn row -> Enum.zip(results.columns, row) |> Map.new() end
  )

# Merge duplicates
Repo.transaction(fn ->
  for {{character, user_id}, records} <- progress_by_char_user do
    IO.puts("Processing duplicates for kanji #{character} and user #{user_id}")

    # Sort by last_reviewed_at to keep the most recent record
    [primary | duplicates] =
      records
      |> Enum.sort_by(
        fn record ->
          record["last_reviewed_at"] || record["inserted_at"] || ~U[1970-01-01 00:00:00Z]
        end,
        :desc
      )

    # Merge stats into the primary record
    merged_reviews =
      duplicates
      |> Enum.reduce(
        {primary["correct_reviews"] || 0, primary["total_reviews"] || 0},
        fn record, {correct, total} ->
          {
            correct + (record["correct_reviews"] || 0),
            total + (record["total_reviews"] || 0)
          }
        end
      )

    # Update the primary record with merged stats
    Repo.query!(
      """
      UPDATE user_kanji_progress
      SET correct_reviews = $1,
          total_reviews = $2
      WHERE id = $3
      """,
      [
        elem(merged_reviews, 0),
        elem(merged_reviews, 1),
        primary["progress_id"]
      ]
    )

    # Delete duplicate records
    duplicate_ids = duplicates |> Enum.map(& &1["progress_id"])

    Repo.query!(
      """
      DELETE FROM user_kanji_progress
      WHERE id = ANY($1)
      """,
      [duplicate_ids]
    )

    IO.puts("Merged #{length(duplicates)} duplicate records for kanji #{character}")
  end
end)

IO.puts("\nDuplicate cleanup completed!")

# Verify no duplicates remain
check_query = """
SELECT k.character, COUNT(*) as count 
FROM user_kanji_progress ukp 
JOIN kanjis k ON k.id = ukp.kanji_id 
GROUP BY k.character 
HAVING COUNT(*) > 1;
"""

case Repo.query!(check_query) do
  %{num_rows: 0} ->
    IO.puts("Verification successful - no duplicates remain!")

  %{rows: remaining} ->
    IO.puts("Warning: Found #{length(remaining)} characters that still have duplicates:")

    for [char, count] <- remaining do
      IO.puts("#{char}: #{count} records")
    end
end
