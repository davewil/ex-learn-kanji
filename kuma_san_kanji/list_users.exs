defmodule KumaSanKanji.Scripts.ListUsers do
  @moduledoc """
  Script to list all users in the system.

  Run with:
  mix run list_users.exs
  """
  alias KumaSanKanji.Accounts.User

  def run do
    require Ash.Query

    {:ok, users} = User |> Ash.read()

    if users == [] do
      IO.puts("No users found in the system!")
    else
      IO.puts("=== Users in the system ===")

      Enum.each(users, fn user ->
        IO.puts("#{user.email} (#{user.id})")
      end)
    end
  end
end

KumaSanKanji.Scripts.ListUsers.run()
