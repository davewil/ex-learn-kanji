IO.puts("Checking database counts...")

kanji_count = KumaSanKanji.Domain.list_kanjis!() |> length()
meaning_count = KumaSanKanji.Domain.list_meanings!() |> length()
pronunciation_count = KumaSanKanji.Domain.list_pronunciations!() |> length()
sentence_count = KumaSanKanji.Domain.list_example_sentences!() |> length()

IO.puts("Kanji: #{kanji_count}")
IO.puts("Meanings: #{meaning_count}")
IO.puts("Pronunciations: #{pronunciation_count}")
IO.puts("Example Sentences: #{sentence_count}")

# Show first kanji details
kanji_list = KumaSanKanji.Domain.list_kanjis!(load: [:meanings, :pronunciations, :example_sentences])
first_kanji = List.first(kanji_list)

if first_kanji do
  IO.puts("\nFirst kanji: #{first_kanji.character}")
  IO.puts("Meanings: #{length(first_kanji.meanings)}")
  IO.puts("Pronunciations: #{length(first_kanji.pronunciations)}")
  IO.puts("Example Sentences: #{length(first_kanji.example_sentences)}")
end
