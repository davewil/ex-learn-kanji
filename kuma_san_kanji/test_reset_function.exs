defmodule KumaSanKanji.Scripts.TestResetFunction do
  @moduledoc """
  Script to test the enhanced reset functionality.

  Run with:
  mix run test_reset_function.exs

  This tests the reset_user_progress function to verify that it:
  1. Correctly deletes existing progress
  2. Creates new kanji progress records
  3. Sets them to be due immediately
  """
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.SRS.UserKanjiProgress

  def run do
    if Mix.env() != :dev do
      IO.puts("❌ This script should only be run in development mode")
      System.halt(1)
    end

    # Get a test user
    require Ash.Query

    {:ok, [user | _]} =
      User
      |> Ash.Query.filter(email == "test@example.com")
      |> Ash.read()

    IO.puts("🧪 Testing reset_user_progress function")
    IO.puts("👤 User: #{user.email} (#{user.id})")
    # Check current progress count
    import Ash.Query

    {:ok, progress_before} =
      UserKanjiProgress
      |> filter(user_id == ^user.id)
      |> Ash.read()

    IO.puts("📊 Current progress records: #{length(progress_before)}")

    # Test with different options
    IO.puts("\n🔄 Resetting with limit: 7, immediate: true")

    case Logic.reset_user_progress(user.id, limit: 7, immediate: true) do
      {:ok, result} ->
        IO.puts("✅ Reset successful!")
        IO.puts("   Cleared: #{result.cleared}")
        IO.puts("   Initialized: #{result.initialized}")
        # Verify results
        {:ok, progress_after} =
          UserKanjiProgress
          |> filter(user_id == ^user.id)
          |> Ash.read()

        IO.puts("📊 Progress records after reset: #{length(progress_after)}")

        # Check if due immediately
        now = DateTime.utc_now()

        due_now =
          Enum.count(progress_after, fn p ->
            DateTime.compare(p.next_review_date, now) in [:lt, :eq]
          end)

        IO.puts("📅 Records due now: #{due_now}")

      {:error, reason} ->
        IO.puts("❌ Reset failed: #{inspect(reason)}")
    end
  end
end

KumaSanKanji.Scripts.TestResetFunction.run()
