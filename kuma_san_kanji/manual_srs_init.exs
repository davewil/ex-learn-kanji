# Manual SRS Progress Creation
# This script manually creates SRS progress records using direct Ash calls

alias KumaSanKanji.Accounts.User
alias KumaSanKanji.Kanji.Kanji
alias KumaSanKanji.SRS.UserKanjiProgress
require Ash.Query

IO.puts("🔧 Manual SRS Progress Initialization")

# Get test user
dev_email = "test@example.com"
IO.puts("Finding user: #{dev_email}")

case User |> Ash.Query.filter(email == ^dev_email) |> Ash.read() do
  {:ok, [user]} ->
    IO.puts("✅ Found user: #{user.username} (ID: #{user.id})")

    # Get first 5 kanji for testing
    case Kanji |> Ash.Query.limit(5) |> Ash.read() do
      {:ok, kanji_list} ->
        IO.puts("📚 Found #{length(kanji_list)} kanji")

        # Create progress records manually
        Enum.each(kanji_list, fn kanji ->
          IO.puts("🔄 Creating progress for: #{kanji.character}")

          # Create progress record directly
          case UserKanjiProgress
               |> Ash.Changeset.for_create(:initialize, %{
                 user_id: user.id,
                 kanji_id: kanji.id
               })
               |> Ash.create() do
            {:ok, progress} ->
              IO.puts("  ✅ Created! Next review: #{progress.next_review_date}")

            {:error, error} ->
              IO.puts("  ❌ Failed:")
              IO.inspect(error, limit: 3)
          end
        end)

        IO.puts("🎯 Manual initialization complete!")

      {:error, error} ->
        IO.puts("❌ Failed to get kanji:")
        IO.inspect(error, limit: 3)
    end

  {:ok, []} ->
    IO.puts("❌ User not found")

  {:error, error} ->
    IO.puts("❌ Error finding user:")
    IO.inspect(error, limit: 3)
end
