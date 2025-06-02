Mix.Task.run("ash.reset", ["--domains", "KumaSanKanji.Domain", "--yes"])
IO.puts("Database reset complete.")
KumaSanKanji.Seeds.insert_initial_data()
IO.puts("Seeds inserted.")
case Ash.read(KumaSanKanji.Kanji.Kanji) do
  {:ok, kanjis} -> IO.puts("Kanji count: #{length(kanjis)}")
  _ -> IO.puts("Error reading kanji.")
end
