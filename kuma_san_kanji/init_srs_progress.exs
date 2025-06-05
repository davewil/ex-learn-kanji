# Initialize SRS progress for development user
# This script sets up SRS progress for testing the quiz system

alias KumaSanKanji.Accounts.User
alias KumaSanKanji.Kanji.Kanji
alias KumaSanKanji.SRS.Logic
require Ash.Query

# Development user credentials
dev_email = "test@example.com"

IO.puts("🚀 Initializing SRS progress for development user...")
IO.puts("Email: #{dev_email}")

# Get the development user
case User |> Ash.Query.filter(email == ^dev_email) |> Ash.read() do
  {:ok, [user]} ->
    IO.puts("✅ Found user: #{user.username} (#{user.id})")

    # Get some kanji to initialize (first 10 for testing)
    case Kanji |> Ash.Query.limit(10) |> Ash.read() do
      {:ok, kanji_list} ->
        IO.puts("📝 Found #{length(kanji_list)} kanji to initialize")

        # Initialize progress for each kanji
        kanji_ids = Enum.map(kanji_list, & &1.id)

        IO.puts("🔄 Initializing SRS progress...")

        case Logic.bulk_initialize_progress(user.id, kanji_ids) do
          {:ok, progress_records} ->
            IO.puts(
              "✅ Successfully initialized #{length(progress_records)} SRS progress records!"
            )

            # Show some details
            Enum.each(Enum.zip(kanji_list, progress_records), fn {kanji, progress} ->
              IO.puts(
                "  📚 #{kanji.character} - Ease Factor: #{progress.ease_factor}, Interval: #{progress.interval} days"
              )
            end)

            # Get user stats
            case Logic.get_user_stats(user.id) do
              {:ok, stats} ->
                IO.puts("")
                IO.puts("📊 User SRS Statistics:")
                IO.puts("  Total Kanji: #{stats.total_kanji}")
                IO.puts("  Due Today: #{stats.due_today}")
                IO.puts("  Total Reviews: #{stats.total_reviews}")
                IO.puts("  Correct Reviews: #{stats.correct_reviews}")
                IO.puts("  Accuracy: #{stats.accuracy}%")

              {:error, error} ->
                IO.puts("⚠️  Warning: Could not get user stats")
                IO.inspect(error)
            end

          {:error, error} ->
            IO.puts("❌ Failed to initialize SRS progress:")
            IO.inspect(error)
        end

      {:error, error} ->
        IO.puts("❌ Failed to get kanji:")
        IO.inspect(error)
    end

  {:ok, []} ->
    IO.puts("❌ Development user not found. Please run create_dev_user.exs first.")

  {:error, error} ->
    IO.puts("❌ Error finding user:")
    IO.inspect(error)
end

IO.puts("")
IO.puts("🎯 Next steps:")
IO.puts("1. Start the server: mix phx.server")
IO.puts("2. Navigate to: http://localhost:4000")
IO.puts("3. Login with: test@example.com / password123")
IO.puts("4. Go to: http://localhost:4000/quiz")
IO.puts("5. Test the SRS quiz system!")
