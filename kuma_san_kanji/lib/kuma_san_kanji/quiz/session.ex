defmodule KumaSanKanji.Quiz.Session do
  @moduledoc """
  Manages user quiz session state to allow users to resume interrupted quiz sessions.

  This module:
  - Securely stores session state
  - Provides functions to save and restore quiz sessions
  - Handles session expiration
  - Validates session data
  """
  alias KumaSanKanji.Domain

  # Store session in either ETS (for dev/test) or a database table (for production)
  # For simplicity in this implementation, we'll use a GenServer with ETS
  use GenServer

  # 24-hour session expiry
  @session_expiry_seconds 86_400
  @table_name :quiz_sessions

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Saves the current quiz session state for a user.

  ## Parameters
  - session_data: Map containing session information (user_id, current_kanji_id, etc.)

  ## Returns
  - {:ok, session_id} | {:error, reason}
  """
  def save(session_data) when is_map(session_data) do
    # Validate required fields
    with :ok <- validate_session_data(session_data),
         session_id = generate_session_id(),
         timestamp = System.system_time(:second) do
      session_record =
        Map.merge(session_data, %{
          id: session_id,
          created_at: timestamp,
          expires_at: timestamp + @session_expiry_seconds
        })

      GenServer.call(__MODULE__, {:save_session, session_record})
    end
  end

  @doc """
  Gets the most recent unexpired session for a user.

  ## Parameters
  - user_id: The ID of the user

  ## Returns
  - {:ok, session} | {:error, :not_found} | {:error, :expired}
  """
  def get_for_user(user_id) when is_binary(user_id) do
    GenServer.call(__MODULE__, {:get_user_session, user_id})
  end

  @doc """
  Restores a specific session for a user by session ID.

  ## Parameters
  - user_id: The ID of the user
  - session_id: The session ID to restore

  ## Returns
  - {:ok, session} | {:error, reason}
  """
  def restore_for_user(user_id, session_id) when is_binary(user_id) and is_binary(session_id) do
    case get_for_user(user_id) do
      {:ok, session} ->
        if session.id == session_id do
          case get_kanji_for_session(session) do
            {:ok, kanji} ->
              # Return restored quiz state matching format from initialize_quiz_session
              {:ok,
               %{
                 current_kanji: kanji,
                 answers_count: session.answers_count,
                 last_answer_times: session.last_answer_times
               }}

            {:error, reason} ->
              {:error, reason}
          end
        else
          {:error, :session_id_mismatch}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Deletes a user's session.

  ## Parameters
  - user_id: The ID of the user
  - session_id: Optional session ID to delete a specific session

  ## Returns
  - :ok
  """
  def delete(user_id, session_id \\ nil) do
    GenServer.call(__MODULE__, {:delete_session, user_id, session_id})
  end

  # Server Callbacks

  @impl true
  def init(_) do
    table = :ets.new(@table_name, [:named_table, :set, :protected])
    {:ok, %{table: table}}
  end

  @impl true
  def handle_call({:save_session, session}, _from, state) do
    true = :ets.insert(@table_name, {session.user_id, session})
    {:reply, {:ok, session.id}, state}
  end

  @impl true
  def handle_call({:get_user_session, user_id}, _from, state) do
    current_time = System.system_time(:second)

    result =
      case :ets.lookup(@table_name, user_id) do
        [{^user_id, session}] ->
          if session.expires_at > current_time do
            {:ok, session}
          else
            # Session is expired, delete it
            :ets.delete(@table_name, user_id)
            {:error, :expired}
          end

        [] ->
          {:error, :not_found}
      end

    {:reply, result, state}
  end

  @impl true
  def handle_call({:delete_session, user_id, nil}, _from, state) do
    :ets.delete(@table_name, user_id)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete_session, user_id, session_id}, _from, state) do
    case :ets.lookup(@table_name, user_id) do
      [{^user_id, session}] when session.id == session_id ->
        :ets.delete(@table_name, user_id)

      _ ->
        :ok
    end

    {:reply, :ok, state}
  end

  # Private helpers

  defp validate_session_data(session_data) do
    required_fields = [:user_id, :current_kanji_id, :answers_count]

    if Enum.all?(required_fields, &Map.has_key?(session_data, &1)) do
      :ok
    else
      missing = Enum.filter(required_fields, &(!Map.has_key?(session_data, &1)))
      {:error, "Missing required fields: #{inspect(missing)}"}
    end
  end

  defp generate_session_id do
    Ash.UUID.generate()
  end

  defp get_kanji_for_session(session) do
    # Use the domain to get the kanji by ID
    case Domain.get_kanji_by_id(%{id: session.current_kanji_id}) do
      {:ok, kanji} when not is_nil(kanji) ->
        # Load meanings and pronunciations to match quiz state format
        try do
          # Use Ash.Query to load the relationships
          {:ok, kanji_with_relations} =
            kanji
            |> Ash.Query.load([:meanings, :pronunciations])
            |> Ash.read_one()

          {:ok, kanji_with_relations}
        rescue
          e -> {:error, Exception.message(e)}
        end

      _ ->
        {:error, :kanji_not_found}
    end
  end
end
