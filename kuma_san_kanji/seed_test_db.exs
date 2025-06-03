# Test database seeding script
# This script seeds the test database with initial data

# Start the application in test mode
Mix.Task.run("app.start")

IO.puts("Starting test database seeding...")

# Reset test database to ensure clean state
{:ok, _} = Mix.Task.run("ash.reset", ["--domains", "KumaSanKanji.Domain", "--yes"])
IO.puts("Test database reset complete.")

# Insert seed data
IO.puts("Inserting test seed data...")
KumaSanKanji.Seeds.insert_initial_data()

# Verify seeding was successful
alias KumaSanKanji.Kanji.Kanji
case Ash.read(Kanji) do
  {:ok, kanjis} ->
    IO.puts("Test seeding complete! Inserted #{length(kanjis)} kanji records.")
    if length(kanjis) > 0 do
      IO.puts("First few kanji in test database:")
      kanjis
      |> Enum.take(3)
      |> Enum.each(fn kanji -> IO.puts("  - #{kanji.character}") end)
    end

  {:error, reason} ->
    IO.puts("Error verifying test seed data: #{inspect(reason)}")
end

IO.puts("Test database seeding completed successfully!")
