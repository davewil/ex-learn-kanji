# Test Logic Functions
# This script tests the SRS Logic module functions

alias KumaSanKanji.Accounts.User
alias KumaSanKanji.SRS.Logic
require Ash.Query

IO.puts("🧪 Testing SRS Logic Functions")

# Get test user
dev_email = "test@example.com"

case User |> Ash.Query.filter(email == ^dev_email) |> Ash.read() do
  {:ok, [user]} ->
    IO.puts("✅ Found user: #{user.username} (ID: #{user.id})")

    # Test get_due_kanji function
    IO.puts("📚 Testing get_due_kanji function...")

    case Logic.get_due_kanji(user.id, 3) do
      {:ok, due_kanji} ->
        IO.puts("✅ get_due_kanji returned #{length(due_kanji)} kanji")

        Enum.each(due_kanji, fn progress ->
          IO.puts("  - Kanji ID: #{progress.kanji_id}, Next review: #{progress.next_review_date}")
        end)

        # Test record_review function with first kanji
        if length(due_kanji) > 0 do
          first_progress = List.first(due_kanji)
          IO.puts("🎯 Testing record_review function...")

          case Logic.record_review(first_progress.id, :correct, user.id) do
            {:ok, updated_progress} ->
              IO.puts("✅ record_review successful!")
              IO.puts("  - Repetitions: #{updated_progress.repetitions}")
              IO.puts("  - Next review: #{updated_progress.next_review_date}")

            {:error, error} ->
              IO.puts("❌ record_review failed:")
              IO.inspect(error, limit: 3)
          end
        end

      {:error, error} ->
        IO.puts("❌ get_due_kanji failed:")
        IO.inspect(error, limit: 3)
    end

    # Test get_user_stats function
    IO.puts("📊 Testing get_user_stats function...")

    case Logic.get_user_stats(user.id) do
      {:ok, stats} ->
        IO.puts("✅ get_user_stats successful!")
        IO.inspect(stats, limit: 5)

      {:error, error} ->
        IO.puts("❌ get_user_stats failed:")
        IO.inspect(error, limit: 3)
    end

  {:ok, []} ->
    IO.puts("❌ User not found")

  {:error, error} ->
    IO.puts("❌ Error finding user:")
    IO.inspect(error, limit: 3)
end

IO.puts("🎯 Logic function testing complete!")
