defmodule KumaSanKanji.Auth do
  @moduledoc """
  The Auth context module handles authentication related functions.
  """

  alias KumaSanKanji.Accounts.User

  # Maximum age for session tokens in seconds
  @max_token_age 60 * 60 * 24 * 7 # 7 days

  @doc """
  Logs in a user by email and password.
  Returns `{:ok, user}` if successful, otherwise `{:error, reason}`.
  """
  def login(email, password) do
    # Perform the login by email
    case User.login(email, password) do
      {:ok, nil} -> 
        # Handle case where no user is found
        {:error, :not_found}
        
      {:ok, []} -> 
        # Handle empty list result
        {:error, :not_found}
        
      {:ok, [user | _]} ->
        # Handle list result - verify password
        if user.hashed_password && Pbkdf2.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
        
      {:ok, user} ->
        # Handle single user result - verify password
        if user.hashed_password && Pbkdf2.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
        
      error -> 
        # Pass through other errors
        error
    end
  end

  @doc """
  Gets a user by ID.
  Returns `{:ok, user}` if found, otherwise `{:error, :not_found}`.
  """
  def get_user(user_id) do
    require Ash.Query

    result = User
    |> Ash.Query.filter(id == ^user_id)
    |> Ash.read_one()
    
    case result do
      {:ok, nil} -> {:error, :not_found}
      other -> other
    end
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

  @doc """
  Verifies a session token.
  Returns `{:ok, user_id}` if valid, otherwise `{:error, reason}`.
  """
  def verify_session_token(token) do
    Phoenix.Token.verify(KumaSanKanjiWeb.Endpoint, "user auth", token, max_age: @max_token_age)
  end

  @doc """
  Extracts and validates a user from the session.
  Returns `{:ok, user}` if valid, otherwise `{:error, reason}`.
  """
  def get_user_from_session(user_id, token) when is_binary(user_id) and is_binary(token) do
    with {:ok, verified_user_id} <- verify_session_token(token),
         true <- verified_user_id == user_id,
         {:ok, user} <- get_user(user_id) do
      {:ok, user}
    else
      _error -> {:error, :invalid_session}
    end
  end

  def get_user_from_session(_user_id, _token), do: {:error, :invalid_session}
end
