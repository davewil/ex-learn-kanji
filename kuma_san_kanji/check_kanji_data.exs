# Check if the seed data exists in the database
alias KumaSanKanji.Kanji.Kanji
alias KumaSanKanji.Kanji.Meaning

case Ash.read(Kanji) do
  {:ok, kanjis} ->
    IO.puts("Found #{length(kanjis)} kanji records in the database.")

    if length(kanjis) > 0 do
      kanji = List.first(kanjis)
      IO.puts("First kanji: #{kanji.character}")
      IO.puts("ID: #{kanji.id}")

      # Get meanings for this kanji
      {:ok, [kanji_with_meanings]} = Kanji.get_by_id(kanji.id, load: [:meanings])

      if kanji_with_meanings.meanings && length(kanji_with_meanings.meanings) > 0 do
        meanings = Enum.map(kanji_with_meanings.meanings, & &1.value) |> Enum.join(", ")
        IO.puts("Meanings: #{meanings}")
      else
        IO.puts("No meanings found for this kanji.")
      end
    end

  _ ->
    IO.puts("Error: Could not read kanji data.")
end

# Count all kanji
IO.puts("Total kanji count: #{Kanji.count_all()}")

# If the count is 0, try to run the seed function
if Kanji.count_all() == 0 do
  IO.puts("No kanji found. Running seed function...")
  KumaSanKanji.Seeds.insert_initial_data()
  IO.puts("Seed function completed. New kanji count: #{Kanji.count_all()}")
end
