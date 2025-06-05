defmodule KumaSanKanji.Auth do
  @moduledoc """
  The Auth context module handles authentication related functions.
  """

  alias KumaSanKanji.Accounts.User

  # Maximum age for session tokens in seconds
  # 7 days
  @max_token_age 60 * 60 * 24 * 7

  @doc """
  Logs in a user by email and password.
  Returns `{:ok, user}` if successful, otherwise `{:error, reason}`.
  """
  def login(email, password) do
    require Ash.Query

    case User.login(email, password) do
      {:ok, %User{} = user} ->
        {:ok, user}

      {:ok, [%User{} = user]} ->
        {:ok, user}

      {:ok, []} ->
        {:error, :not_found}

      {:error, %Ash.Error.Invalid{errors: errors}} ->
        if Enum.any?(errors, fn err -> Map.get(err, :field) == :password end) do
          {:error, :invalid_credentials}
        else
          {:error, %Ash.Error.Invalid{errors: errors}}
        end

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Gets a user by ID.
  Returns `{:ok, user}` if found, otherwise `{:error, :not_found}`.
  """
  def get_user(user_id) do
    require Ash.Query

    case User |> Ash.Query.filter(id == ^user_id) |> Ash.read_one() do
      {:ok, nil} -> {:error, :not_found}
      {:ok, user} -> {:ok, user}
      {:error, _} = err -> err
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
