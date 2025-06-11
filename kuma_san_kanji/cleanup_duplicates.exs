defmodule KumaSanKanji.CleanupDuplicates do
  alias KumaSanKanji.Domain
  require Ash.Query

  def run do
    IO.puts("Cleaning up duplicate meanings, pronunciations, and example sentences...")

    cleanup_duplicate_meanings()
    cleanup_duplicate_pronunciations()
    cleanup_duplicate_example_sentences()

    IO.puts("Cleanup completed!")
  end

  defp cleanup_duplicate_meanings do
    IO.puts("Cleaning up duplicate meanings...")

    # Get all meanings grouped by kanji_id, value, and language
    meanings = KumaSanKanji.Kanji.Meaning
      |> Ash.read!(authorize?: false)

    meanings
    |> Enum.group_by(&{&1.kanji_id, &1.value, &1.language || "en"})
    |> Enum.filter(fn {_key, group} -> length(group) > 1 end)
    |> Enum.each(fn {key, duplicates} ->
      {kanji_id, value, language} = key
      IO.puts("Found #{length(duplicates)} duplicate meanings for kanji #{kanji_id}, value: #{value}, language: #{language}")

      # Keep the first one, delete the rest
      [keep | delete] = duplicates
      IO.puts("Keeping meaning with ID: #{keep.id}")

      Enum.each(delete, fn meaning ->
        IO.puts("Deleting duplicate meaning with ID: #{meaning.id}")
        KumaSanKanji.Kanji.Meaning
        |> Ash.destroy!(meaning, authorize?: false)
      end)
    end)
  end

  defp cleanup_duplicate_pronunciations do
    IO.puts("Cleaning up duplicate pronunciations...")

    # Get all pronunciations grouped by kanji_id, value, and type
    pronunciations = KumaSanKanji.Kanji.Pronunciation
      |> Ash.read!(authorize?: false)

    pronunciations
    |> Enum.group_by(&{&1.kanji_id, &1.value, &1.type})
    |> Enum.filter(fn {_key, group} -> length(group) > 1 end)
    |> Enum.each(fn {key, duplicates} ->
      {kanji_id, value, type} = key
      IO.puts("Found #{length(duplicates)} duplicate pronunciations for kanji #{kanji_id}, value: #{value}, type: #{type}")

      # Keep the first one, delete the rest
      [keep | delete] = duplicates
      IO.puts("Keeping pronunciation with ID: #{keep.id}")

      Enum.each(delete, fn pronunciation ->
        IO.puts("Deleting duplicate pronunciation with ID: #{pronunciation.id}")
        KumaSanKanji.Kanji.Pronunciation
        |> Ash.destroy!(pronunciation, authorize?: false)
      end)
    end)
  end

  defp cleanup_duplicate_example_sentences do
    IO.puts("Cleaning up duplicate example sentences...")

    # Get all example sentences grouped by kanji_id, japanese, translation, and language
    sentences = KumaSanKanji.Kanji.ExampleSentence
      |> Ash.read!(authorize?: false)

    sentences
    |> Enum.group_by(&{&1.kanji_id, &1.japanese || "", &1.translation, &1.language || "en"})
    |> Enum.filter(fn {_key, group} -> length(group) > 1 end)
    |> Enum.each(fn {key, duplicates} ->
      {kanji_id, japanese, translation, language} = key
      IO.puts("Found #{length(duplicates)} duplicate sentences for kanji #{kanji_id}, japanese: #{japanese}, translation: #{translation}, language: #{language}")

      # Keep the first one, delete the rest
      [keep | delete] = duplicates
      IO.puts("Keeping sentence with ID: #{keep.id}")

      Enum.each(delete, fn sentence ->
        IO.puts("Deleting duplicate sentence with ID: #{sentence.id}")
        KumaSanKanji.Kanji.ExampleSentence
        |> Ash.destroy!(sentence, authorize?: false)
      end)
    end)
  end
end

# Run the cleanup
KumaSanKanji.CleanupDuplicates.run()
