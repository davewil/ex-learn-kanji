# Direct SQL approach to initialize SRS data
alias KumaSanKanji.Repo
import Ecto.Query

IO.puts("🔧 Direct SQL SRS Initialization")

# Get user by email
user_query = from(u in "users", where: u.email == "test@example.com", select: [u.id, u.username])

case Repo.all(user_query) do
  [[user_id, username]] ->
    IO.puts("✅ Found user: #{username} (#{user_id})")

    # Get some kanji IDs
    kanji_query = from(k in "kanjis", limit: 5, select: [k.id, k.character])

    case Repo.all(kanji_query) do
      kanji_data when length(kanji_data) > 0 ->
        IO.puts("📚 Found #{length(kanji_data)} kanji")

        # Check if progress already exists
        progress_query =
          from(p in "user_kanji_progress",
            where: p.user_id == ^user_id,
            select: count(p.id)
          )

        existing_count = Repo.one(progress_query)
        IO.puts("📊 Existing progress records: #{existing_count}")

        if existing_count == 0 do
          IO.puts("🔄 Creating SRS progress records...")

          # Create progress records for each kanji
          Enum.each(kanji_data, fn [kanji_id, character] ->
            progress_attrs = %{
              id: Ecto.UUID.generate(),
              user_id: user_id,
              kanji_id: kanji_id,
              next_review_date: DateTime.utc_now(),
              interval: 1,
              ease_factor: Decimal.new("2.5"),
              repetitions: 0,
              total_reviews: 0,
              correct_reviews: 0,
              inserted_at: DateTime.utc_now(),
              updated_at: DateTime.utc_now()
            }

            case Repo.insert_all("user_kanji_progress", [progress_attrs]) do
              {1, _} ->
                IO.puts("  ✅ Created progress for: #{character}")

              _ ->
                IO.puts("  ❌ Failed to create progress for: #{character}")
            end
          end)

          IO.puts("🎯 SRS initialization complete!")
        else
          IO.puts("ℹ️  Progress records already exist, skipping creation")
        end

        # Show final stats
        final_count = Repo.one(progress_query)
        IO.puts("📈 Total progress records: #{final_count}")

      [] ->
        IO.puts("❌ No kanji found")
    end

  [] ->
    IO.puts("❌ User not found")

  multiple ->
    IO.puts("⚠️  Multiple users found: #{length(multiple)}")
end

IO.puts("")
IO.puts("🎯 Next steps:")
IO.puts("1. Login at: http://localhost:4000/users/log_in")
IO.puts("2. Email: test@example.com")
IO.puts("3. Password: password123")
IO.puts("4. Visit quiz: http://localhost:4000/quiz")
IO.puts("5. Test the SRS system!")
