defmodule KumaSanKanji.Scripts.ResetTestUserProgress do
  require Ash.Query
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.Kanji.Kanji
  alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}

  def reset_progress do
    # Find test user
    email = "test@example.com"
    IO.puts("\n🔍 Looking for test user with email: #{email}...")

    user_query =
      User
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter([email: email])

    case Ash.read(user_query) do
      {:ok, [user]} ->
        # Get current user progress
        progress_query =
          UserKanjiProgress
          |> Ash.Query.for_read(:read)
          |> Ash.Query.filter([user_id: user.id])

        case Ash.read(progress_query) do
          {:ok, progress_records} ->
            progress_count = length(progress_records)
            IO.puts("\n🗑️  Found #{progress_count} progress records for test user...")            # Delete all progress records
            Enum.each(progress_records, fn record ->
              Ash.destroy!(record)
            end)

            IO.puts("✅ Deleted all progress records")

            # Get first 10 kanji to initialize progress for
            kanji_query =
              Kanji
              |> Ash.Query.for_read(:read)
              |> Ash.Query.limit(10)

            case Ash.read(kanji_query) do
              {:ok, kanji_list} ->
                IO.puts("\n📚 Initializing progress for #{length(kanji_list)} kanji...")                # Initialize progress for each kanji
                case Logic.bulk_initialize_progress(user.id, Enum.map(kanji_list, & &1.id)) do
                  {:ok, new_progress} ->
                    IO.puts("✅ Created #{length(new_progress)} new progress records")
                    IO.puts("\nTest user progress has been reset successfully! 🎉")
                    IO.puts("You can now test the quiz interface with fresh progress.")

                  {:error, error} ->
                    IO.puts("❌ Error initializing progress: #{inspect(error)}")
                end

              {:error, error} ->
                IO.puts("❌ Error getting kanji: #{inspect(error)}")
            end

          {:error, error} ->
            IO.puts("❌ Error getting progress records: #{inspect(error)}")
        end

      {:ok, []} ->
        IO.puts("❌ Test user not found! Please run create_dev_user.exs first.")

      {:error, error} ->
        IO.puts("❌ Error finding test user: #{inspect(error)}")
    end
  end
end

# Run the reset script
KumaSanKanji.Scripts.ResetTestUserProgress.reset_progress()
