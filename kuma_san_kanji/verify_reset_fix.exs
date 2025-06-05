#!/usr/bin/env elixir

# Test script to verify the fixed reset_user_progress function
Mix.install([:ash, :ash_sqlite])
Application.ensure_all_started(:kuma_san_kanji)

alias KumaSanKanji.SRS.Logic
alias KumaSanKanji.SRS.UserKanjiProgress
alias KumaSanKanji.Accounts

require Logger

defmodule TestReset do
  def run do
    IO.puts("\n=== Testing Fixed SRS Reset Function ===\n")
    
    # Get the first user
    case find_user() do
      {:ok, user} ->
        test_reset_function(user)
      
      {:error, message} ->
        IO.puts("❌ #{message}")
    end
  end
  
  def find_user do
    case Accounts.User |> Ash.Query.limit(1) |> Ash.read() do
      {:ok, [user | _]} -> 
        IO.puts("✅ Found user: #{user.email} (ID: #{user.id})")
        {:ok, user}
      
      {:ok, []} -> 
        {:error, "No users found. Please create a test user first."}
      
      {:error, error} -> 
        {:error, "Error finding users: #{inspect(error)}"}
    end
  end
  
  def test_reset_function(user) do
    # First check existing progress
    IO.puts("\n📊 Checking existing progress...")
    case get_progress_count(user.id) do
      {:ok, count} ->
        IO.puts("Found #{count} existing progress records")
        
        # Test the reset function
        IO.puts("\n🔄 Resetting user progress (limit: 5)...")
        case Logic.reset_user_progress(user.id, limit: 5, immediate: true) do
          {:ok, result} ->
            IO.puts("✅ Reset successful!")
            IO.puts("- Cleared: #{result.cleared} records")
            IO.puts("- Initialized: #{result.initialized} new records")
            
            # Verify the new records
            case get_progress_records(user.id) do
              {:ok, records} ->
                IO.puts("\n📊 After reset: #{length(records)} records")
                
                # Show the first record
                if length(records) > 0 do
                  first = List.first(records)
                  IO.puts("\nSample record:")
                  IO.puts("- ID: #{first.id}")
                  IO.puts("- Kanji ID: #{first.kanji_id}")
                  IO.puts("- Next review: #{first.next_review_date}")
                  
                  # Check if due date is immediate (within the last hour)
                  now = DateTime.utc_now()
                  diff = DateTime.diff(now, first.next_review_date, :second)
                  
                  if diff >= 0 && diff < 3600 do
                    IO.puts("✅ Review date is immediate (within the last hour)")
                  else
                    IO.puts("❌ Review date is NOT immediate: #{diff} seconds difference")
                  end
                end
                
              {:error, error} ->
                IO.puts("❌ Error retrieving progress after reset: #{inspect(error)}")
            end
          
          {:error, reason} ->
            IO.puts("❌ Reset failed: #{inspect(reason)}")
        end
      
      {:error, error} ->
        IO.puts("❌ Error getting progress: #{inspect(error)}")
    end
  end
  
  defp get_progress_count(user_id) do
    case UserKanjiProgress |> Ash.Query.filter(user_id == ^user_id) |> Ash.read() do
      {:ok, records} -> {:ok, length(records)}
      {:error, error} -> {:error, error}
    end
  end
  
  defp get_progress_records(user_id) do
    UserKanjiProgress |> Ash.Query.filter(user_id == ^user_id) |> Ash.read()
  end
end

TestReset.run()
