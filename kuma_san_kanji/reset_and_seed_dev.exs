defmodule ResetAndSeed do
  def run do
    IO.puts("Starting database reset...")    # Reset the database
    Mix.Task.run("ash_sqlite.drop")
    Mix.Task.run("ash_sqlite.generate")
    Mix.Task.run("ash_sqlite.create")
    Mix.Task.run("ash_sqlite.migrate")
    IO.puts("Database reset complete!")

    # Insert seed data
    IO.puts("Inserting seed data...")
    KumaSanKanji.Seeds.insert_initial_data()
    IO.puts("Seed data inserted!")

    # Verify data was inserted
    case Ash.read(KumaSanKanji.Kanji.Kanji) do
      {:ok, kanjis} ->
        IO.puts("Verification: Found #{length(kanjis)} kanji records in the database.")
        Enum.each(kanjis, fn kanji ->
          IO.puts("Kanji: #{kanji.character}")
        end)
      _ ->
        IO.puts("Error: Could not verify kanji data.")
    end

    IO.puts("Process completed successfully!")
  end
end

ResetAndSeed.run()
