IO.puts("Script started")

try do
  IO.puts("Starting database seed process...")
  
  # Run the seed function
  IO.puts("Calling KumaSanKanji.Seeds.insert_initial_data()...")
  KumaSanKanji.Seeds.insert_initial_data()
  IO.puts("Seed function called successfully")
  
  # Check if data was inserted
  alias KumaSanKanji.Kanji.Kanji
  IO.puts("Checking kanji data...")
  
  case Ash.read(Kanji) do
    {:ok, kanjis} -> 
      IO.puts("Database query successful")
      IO.puts("Found #{length(kanjis)} kanji records")
      
      if length(kanjis) > 0 do
        Enum.each(kanjis, fn kanji -> 
          IO.puts("- Kanji: #{kanji.character}")
        end)
      end
      
    {:error, reason} -> 
      IO.puts("Error querying database: #{inspect(reason)}")
  end
  
  IO.puts("Script completed successfully!")
rescue
  e -> 
    IO.puts("Error during script execution:")
    IO.puts(Exception.message(e))
    IO.puts(Exception.format_stacktrace(__STACKTRACE__))
end
