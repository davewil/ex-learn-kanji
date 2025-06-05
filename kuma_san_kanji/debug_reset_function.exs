#!/usr/bin/env elixir

# Debugging script for the SRS.Logic.reset_user_progress function
# 
# This script will help us identify why we get an ArgumentError when using
# the reset progress functionality in the web UI

# Start the application
Mix.install([:ash, :ash_sqlite])
Application.ensure_all_started(:kuma_san_kanji)

alias KumaSanKanji.SRS.Logic
alias KumaSanKanji.SRS.UserKanjiProgress
alias KumaSanKanji.Accounts

require Logger
Logger.configure(level: :debug)

defmodule KumaSanKanji.ResetDebugger do
  def run do
    IO.puts("=== Starting SRS Reset Function Debugging ===\n")
    
    # Find a test user
    case Accounts.User |> Ash.Query.limit(1) |> Ash.read() do
      {:ok, [user | _]} ->
        IO.puts("✅ Found user: #{user.email} (ID: #{user.id})")
        debug_reset_function(user.id)
      
      {:ok, []} ->
        IO.puts("❌ No users found! Please create a test user first.")
      
      {:error, error} ->
        IO.puts("❌ Error finding user: #{inspect(error)}")
    end
  end
  
  def debug_reset_function(user_id) do
    IO.puts("\n=== Debugging Logic.reset_user_progress/2 ===")
    
    # Check existing progress first
    check_existing_progress(user_id)
    
    # Try the reset function with explicit debug prints
    IO.puts("\n🔄 Calling reset_user_progress...")
    
    result = try do
      Logic.reset_user_progress(user_id, limit: 5, immediate: true)
    rescue
      e ->
        IO.puts("\n❌ EXCEPTION RAISED: #{inspect(e)}")
        IO.puts("\nStacktrace:")
        System.stacktrace() |> Enum.each(fn line -> IO.puts("  #{inspect(line)}") end)
        {:error, :exception, e}
    end
    
    IO.puts("\nReset result: #{inspect(result)}")
    
    # Check progress after attempt
    check_existing_progress(user_id)
  end
  
  def check_existing_progress(user_id) do
    case UserKanjiProgress 
      |> Ash.Query.filter(user_id == ^user_id) 
      |> Ash.read() do
      
      {:ok, records} ->
        IO.puts("📊 Current progress records count: #{length(records)}")
        if length(records) > 0 do
          IO.puts("Sample record: #{inspect(List.first(records), pretty: true)}")
        end
      
      {:error, error} ->
        IO.puts("❌ Error checking progress: #{inspect(error)}")
    end
  end
end

# Run the debugger
KumaSanKanji.ResetDebugger.run()
