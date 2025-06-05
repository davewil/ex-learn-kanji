# Simple test of SRS Logic module
alias KumaSanKanji.Accounts.User
alias KumaSanKanji.Kanji.Kanji
alias KumaSanKanji.SRS.Logic
require Ash.Query

IO.puts("Testing SRS Logic module...")

# Test 1: Get user
dev_email = "test@example.com"

case User |> Ash.Query.filter(email == ^dev_email) |> Ash.read() do
  {:ok, [user]} ->
    IO.puts("✅ Found user: #{user.username}")

    # Test 2: Get some kanji
    case Kanji |> Ash.Query.limit(3) |> Ash.read() do
      {:ok, kanji_list} ->
        IO.puts("✅ Found #{length(kanji_list)} kanji")

        # Test 3: Try to initialize one progress record
        first_kanji = List.first(kanji_list)
        IO.puts("🔄 Testing initialize_progress for kanji: #{first_kanji.character}")

        case Logic.initialize_progress(user.id, first_kanji.id) do
          {:ok, progress} ->
            IO.puts("✅ Successfully initialized progress!")
            IO.puts("  Ease Factor: #{progress.ease_factor}")
            IO.puts("  Interval: #{progress.interval}")
            IO.puts("  Next Review: #{progress.next_review_date}")

          {:error, error} ->
            IO.puts("❌ Failed to initialize progress:")
            IO.inspect(error)
        end

      {:error, error} ->
        IO.puts("❌ Failed to get kanji:")
        IO.inspect(error)
    end

  {:ok, []} ->
    IO.puts("❌ User not found")

  {:error, error} ->
    IO.puts("❌ Error finding user:")
    IO.inspect(error)
end
