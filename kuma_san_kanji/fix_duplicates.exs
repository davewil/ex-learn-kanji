Code.compiler_options(ignore_module_conflict: true)

defmodule DuplicateFixer do
  import Ecto.Query
  alias KumaSanKanji.Repo
  
  def fix_duplicates do
    # Get all duplicates
    duplicates = from(k in "kanjis",
      group_by: k.character,
      having: count(k.id) > 1,
      select: %{
        character: k.character,
        count: count(k.id)
      }
    ) |> Repo.all()

    IO.puts("Found #{length(duplicates)} characters with duplicates")

    for %{character: char} <- duplicates do
      fix_character(char)
    end
  end

  def fix_character(char) do
    IO.puts("Processing #{char}")
    
    # Get all IDs for this character, ordered by inserted_at
    kanji_entries = from(k in "kanjis",
      where: k.character == ^char,
      order_by: k.inserted_at,
      select: %{id: k.id, inserted_at: k.inserted_at}
    ) |> Repo.all()
    
    [%{id: keep_id} | duplicates] = kanji_entries
    duplicate_ids = Enum.map(duplicates, & &1.id)

    Repo.transaction(fn ->
      # Get all progress records that need to be migrated
      progress_records = from(p in "user_kanji_progress",
        where: p.kanji_id in ^duplicate_ids,
        select: %{
          id: p.id,
          user_id: p.user_id,
          kanji_id: p.kanji_id,
          total_reviews: p.total_reviews,
          correct_reviews: p.correct_reviews,
          interval: p.interval,
          ease_factor: p.ease_factor,
          last_reviewed_at: p.last_reviewed_at,
          first_reviewed_at: p.first_reviewed_at,
          next_review_date: p.next_review_date,
          last_result: p.last_result,
          repetitions: p.repetitions
        }
      ) |> Repo.all()
      
      if progress_records != [] do
        IO.puts("Found #{length(progress_records)} progress records to migrate")
        
        # For each progress record...
        for progress <- progress_records do
          # Check if a record already exists for the target kanji
          existing = from(p in "user_kanji_progress",
            where: p.user_id == ^progress.user_id and p.kanji_id == ^keep_id,
            select: %{
              id: p.id,
              total_reviews: p.total_reviews,
              correct_reviews: p.correct_reviews,
              interval: p.interval,
              ease_factor: p.ease_factor,
              repetitions: p.repetitions,
              last_reviewed_at: p.last_reviewed_at,
              first_reviewed_at: p.first_reviewed_at,
              last_result: p.last_result,
              next_review_date: p.next_review_date
            }
          ) |> Repo.all() |> List.first()

          if existing do
            # Merge all relevant SRS fields
            IO.puts("Merging progress for user #{progress.user_id}")
            total_reviews = existing.total_reviews + progress.total_reviews
            correct_reviews = existing.correct_reviews + progress.correct_reviews
            interval = max(existing.interval || 1, progress.interval || 1)
            repetitions = max(existing.repetitions || 0, progress.repetitions || 0)
            # Use the higher ease_factor (or fallback to 2.5)
            ease_factor =
              [existing.ease_factor, progress.ease_factor]
              |> Enum.map(&(&1 || 2.5))
              |> Enum.max_by(&Decimal.to_float/1)
            # Use the most recent last_reviewed_at
            last_reviewed_at = Enum.max([existing.last_reviewed_at, progress.last_reviewed_at])
            # Use the earliest first_reviewed_at
            first_reviewed_at = Enum.min([existing.first_reviewed_at, progress.first_reviewed_at])
            # Use the most recent next_review_date
            next_review_date = Enum.max([existing.next_review_date, progress.next_review_date])
            # Use the most recent last_result (if any)
            last_result = progress.last_result || existing.last_result

            Repo.query!("""
            UPDATE user_kanji_progress 
            SET total_reviews = ?, correct_reviews = ?, interval = ?, ease_factor = ?, repetitions = ?, last_reviewed_at = ?, first_reviewed_at = ?, next_review_date = ?, last_result = ?
            WHERE id = ?
            """, [total_reviews, correct_reviews, interval, ease_factor, repetitions, last_reviewed_at, first_reviewed_at, next_review_date, last_result, existing.id])
          else
            # If no existing record, simply update its kanji_id to point to the kept kanji
            IO.puts("Moving progress for user #{progress.user_id} to kept kanji")
            Repo.query!("""
            UPDATE user_kanji_progress 
            SET kanji_id = ?
            WHERE id = ?
            """, [keep_id, progress.id])
          end
        end
      end
      
      # Delete relationships for duplicates
      {del_pron, _} = from(p in "kanji_pronunciations",
        where: p.kanji_id in ^duplicate_ids
      ) |> Repo.delete_all()
      
      IO.puts("Deleted #{del_pron} pronunciations")

      {del_mean, _} = from(m in "kanji_meanings",
        where: m.kanji_id in ^duplicate_ids
      ) |> Repo.delete_all()
      
      IO.puts("Deleted #{del_mean} meanings")

      {del_ex, _} = from(e in "kanji_example_sentences",
        where: e.kanji_id in ^duplicate_ids
      ) |> Repo.delete_all()
      
      IO.puts("Deleted #{del_ex} example sentences")

      # Delete any remaining conflicting progress records
      {del_progress, _} = from(p in "user_kanji_progress",
        where: p.kanji_id in ^duplicate_ids
      ) |> Repo.delete_all()
      
      IO.puts("Deleted #{del_progress} remaining progress records")

      # Delete duplicate kanji entries
      {del_kanji, _} = from(k in "kanjis",
        where: k.id in ^duplicate_ids
      ) |> Repo.delete_all()
      
      IO.puts("Deleted #{del_kanji} duplicate kanji entries")
    end)
  end
end

DuplicateFixer.fix_duplicates()
