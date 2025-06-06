#!/usr/bin/env elixir

# This script directly tests the SRS.Logic.reset_user_progress function

# Ensure the application is started
Mix.Task.run("app.start")

alias KumaSanKanji.SRS.Logic
alias KumaSanKanji.Accounts

IO.puts("\n=== Testing reset_user_progress function ===")

# Find a user
case Accounts.User |> Ash.Query.limit(1) |> Ash.read() do
  {:ok, [user | _]} ->
    IO.puts("Found user: #{user.email}")

    # Call the reset function
    IO.puts("Resetting user progress...")
    result = Logic.reset_user_progress(user.id, limit: 5)
    IO.puts("Result: #{inspect(result)}")

  {:ok, []} ->
    IO.puts("No users found!")

  {:error, error} ->
    IO.puts("Error finding users: #{inspect(error)}")
end
