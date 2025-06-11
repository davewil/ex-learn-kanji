# Reset and seed production database
# This will drop all tables and recreate them, then seed with data

IO.puts("Starting production database reset...")

# Reset the database (drops and recreates all tables)
Mix.Task.run("ash.reset", ["--domains", "KumaSanKanji.Domain", "--yes"])
IO.puts("Database reset complete.")

# Seed the database
KumaSanKanji.Seeds.seed_all()
IO.puts("Seeds inserted.")

# Verify the data
case KumaSanKanji.Domain.count_kanjis() do
  {:ok, count} -> IO.puts("Kanji count: #{count}")
  _ -> IO.puts("Error reading kanji count.")
end

IO.puts("Production database reset and seeding completed!")
