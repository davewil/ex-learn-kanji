defmodule KumaSanKanji.Auth do
  @moduledoc """
  The Auth context module handles authentication related functions.
  """

  alias KumaSanKanji.Accounts.User

  @doc """
  Logs in a user by email and password.
  Returns `{:ok, user}` if successful, otherwise `{:error, reason}`.
  """
  def login(email, password) do
    User.login(email, password)
  end
  @doc """
  Gets a user by ID.
  Returns `{:ok, user}` if found, otherwise `{:error, :not_found}`.
  """
  def get_user(user_id) do
    require Ash.Query
    
    User
    |> Ash.Query.filter(id == ^user_id)
    |> Ash.read_one()
  end

  @doc """
  Creates a new session for a user.
  Returns the session data to be stored in the session.
  """
  def create_session(_conn, user) do
    # Generate a random token for the session
    token = Phoenix.Token.sign(KumaSanKanjiWeb.Endpoint, "user auth", user.id)
    
    %{
      "user_id" => user.id,
      "token" => token
    }
  end
end
