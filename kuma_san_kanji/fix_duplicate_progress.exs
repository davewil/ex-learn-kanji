# Fix duplicate progress records and reinitialize
alias KumaSanKanji.Accounts.User
alias KumaSanKanji.Kanji.Kanji
alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}
require Ash.Query

# Development user credentials
dev_email = "test@example.com"

IO.puts("\n🔍 Looking for test user...")

# Get the development user
case User |> Ash.Query.filter([email: dev_email]) |> Ash.read() do
  {:ok, [user]} ->
    IO.puts("✅ Found user: #{user.username}")    # Get all progress records
    progress_query =
      UserKanjiProgress
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter([user_id: user.id])

    case Ash.read(progress_query) do
      {:ok, progress_records} ->
        IO.puts("\n🗑️  Cleaning up #{length(progress_records)} progress records...")

        # Delete all existing progress
        Enum.each(progress_records, fn record ->
          Ash.destroy!(record)
        end)

        IO.puts("✅ Deleted all progress records")        # Get first 10 kanji to initialize progress for
        kanji_query =
          Kanji
          |> Ash.Query.for_read(:read)
          |> Ash.Query.limit(10)

        case Ash.read(kanji_query) do
          {:ok, kanji_list} ->
            unique_count = length(kanji_list)
            IO.puts("\n📚 Found #{unique_count} unique kanji")
            
            # Initialize progress for unique kanji
            case Logic.bulk_initialize_progress(user.id, Enum.map(kanji_list, & &1.id)) do
              {:ok, new_progress} ->
                IO.puts("✅ Created #{length(new_progress)} new progress records")
                
                # Get user stats
                case Logic.get_user_stats(user.id) do
                  {:ok, stats} ->
                    IO.puts("\n📊 Updated User Stats:")
                    IO.puts("  Total Kanji: #{stats.total_kanji}")
                    IO.puts("  Due Today: #{stats.due_today}")
                    IO.puts("  Accuracy: #{stats.accuracy}%")

                    IO.puts("\n✨ Success! Your progress has been fixed.")
                    IO.puts("🎯 Next steps:")
                    IO.puts("1. Start the server: mix phx.server")
                    IO.puts("2. Go to: http://localhost:4000/quiz")
                    IO.puts("3. Test the quiz interface!")

                  {:error, error} ->
                    IO.puts("⚠️  Warning: Could not get final stats")
                    IO.inspect(error)
                end

              {:error, error} ->
                IO.puts("❌ Failed to initialize new progress:")
                IO.inspect(error)
            end

          {:error, error} ->
            IO.puts("❌ Failed to get unique kanji:")
            IO.inspect(error)
        end

      {:error, error} ->
        IO.puts("❌ Failed to get progress records:")
        IO.inspect(error)
    end

  {:ok, []} ->
    IO.puts("❌ Test user not found with email: #{dev_email}")
    IO.puts("Please run create_dev_user.exs first.")

  {:error, error} ->
    IO.puts("❌ Error finding user:")
    IO.inspect(error)
end
