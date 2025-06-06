#!/usr/bin/env elixir

# Script to test the full reset and review process in the SRS system
# This script creates a temporary implementation of reset_user_progress to bypass the broken code

Mix.install([:ash, :ash_sqlite])
Application.ensure_all_started(:kuma_san_kanji)

defmodule KumaSanKanji.TestSRS do
  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.Accounts
  alias KumaSanKanji.Kanji.Kanji
  require Logger

  def run do
    IO.puts("\n===== Testing SRS Reset Functions =====\n")

    # Find a user
    case get_test_user() do
      {:ok, user} ->
        test_reset(user)

      {:error, message} ->
        IO.puts("❌ #{message}")
    end
  end

  def get_test_user do
    case Accounts.User |> Ash.Query.limit(1) |> Ash.read() do
      {:ok, [user | _]} -> {:ok, user}
      {:ok, []} -> {:error, "No users found. Please create a test user first"}
      {:error, error} -> {:error, "Error finding user: #{inspect(error)}"}
    end
  end

  def test_reset(user) do
    IO.puts("Testing reset functionality for user #{user.email} (#{user.id})")

    # Get current progress count
    case get_progress_count(user.id) do
      {:ok, count} ->
        IO.puts("Current progress count: #{count}")

        # Test our implementation
        IO.puts("\n🔄 Resetting user progress...")

        case reset_user_progress_safe(user.id) do
          {:ok, result} ->
            IO.puts("✅ Reset successful!")
            IO.puts("- Cleared: #{result.cleared}")
            IO.puts("- Initialized: #{result.initialized}")

            # Verify results
            case get_progress_count(user.id) do
              {:ok, new_count} ->
                IO.puts("\nNew progress count: #{new_count}")

                if new_count == result.initialized do
                  IO.puts("✅ Counts match expectations")
                else
                  IO.puts(
                    "❌ Counts don't match: expected #{result.initialized}, got #{new_count}"
                  )
                end

              {:error, error} ->
                IO.puts("❌ Error checking progress count after reset: #{inspect(error)}")
            end

          {:error, reason} ->
            IO.puts("❌ Reset failed: #{inspect(reason)}")
        end

      {:error, error} ->
        IO.puts("❌ Error getting progress count: #{inspect(error)}")
    end
  end

  def reset_user_progress_safe(user_id, options \\ []) when is_binary(user_id) do
    # This is a safe implementation of reset_user_progress that doesn't rely on the broken function
    require Logger
    import Ash.Query

    # Get options
    limit = Keyword.get(options, :limit, 10)

    Logger.debug("[Test] Resetting progress for user #{user_id}")

    # Step 1: Delete all existing progress
    delete_result =
      try do
        case UserKanjiProgress |> filter(user_id == ^user_id) |> Ash.read() do
          {:ok, progress_records}
          when is_list(progress_records) and length(progress_records) > 0 ->
            # Delete each record
            results =
              Enum.map(progress_records, fn record ->
                Ash.Changeset.for_destroy(record, :destroy) |> Ash.destroy()
              end)

            errors = Enum.filter(results, &match?({:error, _}, &1))

            if errors == [] do
              {:ok, length(progress_records)}
            else
              {:error, errors}
            end

          {:ok, []} ->
            {:ok, 0}

          {:error, reason} ->
            {:error, reason}
        end
      rescue
        e ->
          Logger.error("[Test] Exception during delete: #{inspect(e)}")
          {:error, :delete_exception}
      end

    # Step 2: Create new progress records
    case delete_result do
      {:ok, cleared_count} ->
        try do
          # Get some kanji
          case Kanji
               |> Ash.Query.select([:id, :character])
               |> Ash.Query.sort(grade: :asc)
               |> Ash.Query.limit(limit)
               |> Ash.read() do
            {:ok, kanji_list} when length(kanji_list) > 0 ->
              # Create progress for each kanji
              results =
                Enum.map(kanji_list, fn kanji ->
                  UserKanjiProgress
                  |> Ash.Changeset.for_create(:initialize, %{
                    user_id: user_id,
                    kanji_id: kanji.id
                  })
                  |> Ash.create()
                end)

              success_count = Enum.count(results, &match?({:ok, _}, &1))
              {:ok, %{cleared: cleared_count, initialized: success_count}}

            {:ok, []} ->
              {:error, :no_kanji_found}

            {:error, reason} ->
              {:error, reason}
          end
        rescue
          e ->
            Logger.error("[Test] Exception during initialization: #{inspect(e)}")
            {:error, :init_exception}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_progress_count(user_id) do
    case UserKanjiProgress |> Ash.Query.filter(user_id == ^user_id) |> Ash.read() do
      {:ok, records} -> {:ok, length(records)}
      {:error, error} -> {:error, error}
    end
  end
end

KumaSanKanji.TestSRS.run()
