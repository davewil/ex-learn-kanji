defmodule KumaSanKanji.SRS.Logic do
  @moduledoc """
  Core SRS (Spaced Repetition System) logic implementing the SM-2 algorithm.

  This module provides functions for:
  - Calculating review intervals based on performance
  - Managing review schedules
  - Handling edge cases and input validation
  - Concurrent update protection

  Security considerations:
  - All functions validate input parameters
  - User context validation happens at the resource level
  - Rate limiting is handled by the calling context
  """

  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.Kanji.Kanji

  require Ash.Query

  @doc """
  Gets kanji due for review for a specific user.

  ## Parameters
  - user_id: UUID of the user
  - limit: Maximum number of kanji to return (default: 10, max: 50)

  ## Returns
  {:ok, [%UserKanjiProgress{}]} | {:error, reason}
  """
  def get_due_kanji(user_id, limit \\ 10) when is_binary(user_id) do
    # Validate and sanitize limit parameter
    sanitized_limit = sanitize_limit(limit)

    case UserKanjiProgress
         |> Ash.Query.for_read(:due_for_review, %{user_id: user_id, limit: sanitized_limit})
         |> Ash.read() do
      {:ok, progress_records} ->
        # Load kanji data for each progress record
        load_kanji_data(progress_records)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Records a review result and updates the SRS state.

  ## Parameters
  - progress_id: UUID of the UserKanjiProgress record
  - result: :correct | :incorrect | :skip
  - user_id: UUID of the user (for authorization)

  ## Returns
  {:ok, %UserKanjiProgress{}} | {:error, reason}
  """
  def record_review(progress_id, result, user_id)
      when is_binary(progress_id) and result in [:correct, :incorrect, :skip] and
             is_binary(user_id) do
    # First, get the progress record and verify it belongs to the user
    case UserKanjiProgress
         |> Ash.Query.filter(id == ^progress_id)
         |> Ash.read() do
      {:ok, [progress]} ->
        if progress.user_id == user_id do
          # Update with concurrency protection
          update_progress_with_retry(progress, result, 3)
        else
          {:error, :unauthorized}
        end

      {:ok, []} ->
        {:error, :not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Initializes progress tracking for a user-kanji pair.

  ## Parameters
  - user_id: UUID of the user
  - kanji_id: UUID of the kanji

  ## Returns
  {:ok, %UserKanjiProgress{}} | {:error, reason}
  """
  def initialize_progress(user_id, kanji_id)
      when is_binary(user_id) and is_binary(kanji_id) do
    require Logger
    Logger.debug("[SRS.Logic] Initializing progress for user #{user_id}, kanji #{kanji_id}")

    try do
      # Validate that kanji exists
      case Kanji
           |> Ash.Query.filter(id == ^kanji_id)
           |> Ash.read() do
        {:ok, [kanji]} ->
          Logger.debug("[SRS.Logic] Found kanji: #{kanji.character}")

          # Check if progress already exists
          case UserKanjiProgress
               |> Ash.Query.for_read(:get_user_kanji_progress, %{
                 user_id: user_id,
                 kanji_id: kanji_id
               })
               |> Ash.read() do
            {:ok, [existing]} ->
              Logger.debug(
                "[SRS.Logic] Progress already exists for this kanji, returning existing"
              )

              {:ok, existing}

            {:ok, []} ->
              # Create new progress record using the initialize action
              Logger.debug("[SRS.Logic] Creating new progress record")

              UserKanjiProgress
              |> Ash.Changeset.for_create(:initialize, %{user_id: user_id, kanji_id: kanji_id})
              |> Ash.create()

            {:error, reason} ->
              Logger.error("[SRS.Logic] Error checking progress existence: #{inspect(reason)}")
              {:error, reason}
          end

        {:ok, []} ->
          Logger.error("[SRS.Logic] Kanji not found with ID: #{kanji_id}")
          {:error, :kanji_not_found}

        {:error, reason} ->
          Logger.error("[SRS.Logic] Error finding kanji: #{inspect(reason)}")
          {:error, reason}
      end
    rescue
      e ->
        Logger.error(
          "[SRS.Logic] Exception in initialize_progress: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
        )

        {:error, :exception, e}
    end
  end

  @doc """
  Gets user's overall SRS statistics.

  ## Parameters
  - user_id: UUID of the user

  ## Returns
  {:ok, %{total_kanji: integer, due_today: integer, accuracy: float}} | {:error, reason}
  """
  def get_user_stats(user_id) when is_binary(user_id) do
    case UserKanjiProgress
         |> Ash.Query.for_read(:user_stats, %{user_id: user_id})
         |> Ash.read() do
      {:ok, progress_records} ->
        stats = calculate_user_stats(progress_records)
        {:ok, stats}

      {:error, %Ash.Error.Query.NotFound{}} ->
        # Return empty stats for new users
        {:ok,
         %{
           total_kanji: 0,
           due_today: 0,
           total_reviews: 0,
           correct_reviews: 0,
           accuracy: 0.0
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Handles bulk initialization of progress for multiple kanji.
  Useful for setting up a learning set for a user.

  ## Parameters
  - user_id: UUID of the user
  - kanji_ids: List of kanji UUIDs

  ## Returns
  {:ok, [%UserKanjiProgress{}]} | {:error, reason}
  """
  def bulk_initialize_progress(user_id, kanji_ids)
      when is_binary(user_id) and is_list(kanji_ids) do
    # Validate kanji_ids list
    if length(kanji_ids) > 100 do
      {:error, :too_many_kanji}
    else
      # Process in batches to avoid overwhelming the database
      kanji_ids
      |> Enum.chunk_every(20)
      |> Enum.reduce_while({:ok, []}, fn batch, {:ok, acc} ->
        case process_batch(user_id, batch) do
          {:ok, batch_results} -> {:cont, {:ok, acc ++ batch_results}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end
  end

  @doc """
  Resets all quiz progress for a user and prepares kanji for immediate review (dev mode only).

  ## Parameters
  - user_id: UUID of the user
  - options: Keyword list with options
    - :limit - Number of kanji to prepare for immediate review (default: 10)
    - :immediate - If true, makes kanji due immediately (default: true)

  ## Returns
  {:ok, %{cleared: integer, initialized: integer}} | {:error, reason}
  """
  def reset_user_progress(user_id, options \\ []) when is_binary(user_id) do
    if Mix.env() == :dev do
      require Logger
      import Ash.Query

      # Get the number of kanji to initialize
      limit = Keyword.get(options, :limit, 10)

      # The immediate option is no longer needed as records are created with immediate due dates by default
      make_immediate = Keyword.get(options, :immediate, true)

      Logger.debug(
        "[SRS.Logic] Resetting progress for user #{user_id} (limit: #{limit}, immediate: #{make_immediate})"
      )

      # Step 1: Delete all UserKanjiProgress records for this user - with detailed error handling
      delete_result =
        try do
          case UserKanjiProgress |> filter(user_id == ^user_id) |> Ash.read() do
            {:ok, progress_records}
            when is_list(progress_records) and length(progress_records) > 0 ->
              Logger.debug(
                "[SRS.Logic] Found #{length(progress_records)} existing progress records to delete"
              )

              results =
                Enum.map(progress_records, fn record ->
                  # Create a proper destroy changeset using the record itself
                  Logger.debug("[SRS.Logic] Deleting record ID: #{record.id}")
                  Ash.Changeset.for_destroy(record, :destroy) |> Ash.destroy()
                end)

              errors = Enum.filter(results, &match?({:error, _}, &1))

              if errors == [] do
                {:ok, length(progress_records)}
              else
                Logger.error("[SRS.Logic] Errors when deleting progress: #{inspect(errors)}")
                {:error, errors}
              end

            {:ok, []} ->
              # No progress records found, which is fine - just continue with initialization
              Logger.debug("[SRS.Logic] No existing progress records found for user #{user_id}")
              {:ok, 0}

            {:error, %Ash.Error.Query.NotFound{} = error} ->
              # Not found is also fine - just continue with initialization
              Logger.debug(
                "[SRS.Logic] No progress records table found for user #{user_id}: #{inspect(error)}"
              )

              {:ok, 0}

            {:error, reason} ->
              Logger.error("[SRS.Logic] Failed to read progress records: #{inspect(reason)}")
              {:error, reason}
          end
        rescue
          e ->
            Logger.error(
              "[SRS.Logic] Exception in delete operation: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
            )

            {:error, :exception, e}
        end

      # Step 2: Create new progress for a few kanji with immediate due date
      case delete_result do
        {:ok, cleared_count} ->
          # Get kanji IDs for initialization
          Logger.debug("[SRS.Logic] Finding #{limit} kanji for initialization...")

          try do
            kanji_ids_result =
              Kanji
              |> Ash.Query.select([:id, :character, :grade])
              # Start with easier kanji first
              |> Ash.Query.sort(grade: :asc)
              |> Ash.Query.limit(limit)
              |> Ash.read()

            case kanji_ids_result do
              {:ok, kanji_list} when is_list(kanji_list) and length(kanji_list) > 0 ->
                kanji_ids = Enum.map(kanji_list, & &1.id)
                kanji_chars = Enum.map_join(kanji_list, ", ", & &1.character)

                Logger.debug("[SRS.Logic] Initializing progress for kanji: #{kanji_chars}")

                # Initialize progress for these kanji
                try do
                  Logger.debug(
                    "[SRS.Logic] Calling bulk_initialize_progress with #{length(kanji_ids)} kanji IDs"
                  )

                  init_result = bulk_initialize_progress(user_id, kanji_ids)

                  case init_result do
                    {:ok, initialized_progress}
                    when is_list(initialized_progress) and length(initialized_progress) > 0 ->
                      # The progress records are already initialized with the current date as next_review_date
                      # so we don't need to update them separately
                      Logger.debug(
                        "[SRS.Logic] Successfully reset progress. Cleared: #{cleared_count}, Initialized: #{length(initialized_progress)}"
                      )

                      {:ok, %{cleared: cleared_count, initialized: length(initialized_progress)}}

                    {:ok, []} ->
                      Logger.error(
                        "[SRS.Logic] No progress records were created during initialization"
                      )

                      {:error, :no_progress_created}

                    {:error, init_error} ->
                      Logger.error(
                        "[SRS.Logic] Failed to initialize progress: #{inspect(init_error)}"
                      )

                      {:error, init_error}
                  end
                rescue
                  e ->
                    Logger.error(
                      "[SRS.Logic] Exception in bulk_initialize_progress: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
                    )

                    {:error, :exception, e}
                end

              {:ok, []} ->
                Logger.error("[SRS.Logic] No kanji found for initialization")
                {:error, :no_kanji_available}

              {:error, kanji_error} ->
                Logger.error(
                  "[SRS.Logic] Failed to get kanji for initialization: #{inspect(kanji_error)}"
                )

                {:error, kanji_error}
            end
          rescue
            e ->
              Logger.error(
                "[SRS.Logic] Exception finding kanji: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
              )

              {:error, :exception, e}
          end

        {:error, reason} ->
          Logger.error("[SRS.Logic] Error during progress reset: #{inspect(reason)}")
          {:error, reason}
      end
    else
      {:error, :not_allowed}
    end
  end

  # Private helper functions

  defp sanitize_limit(limit) when is_integer(limit) and limit > 0 and limit <= 50, do: limit
  defp sanitize_limit(limit) when is_integer(limit) and limit > 50, do: 50
  defp sanitize_limit(_), do: 10

  defp load_kanji_data(progress_records) do
    # Extract kanji IDs and load them efficiently
    kanji_ids = Enum.map(progress_records, & &1.kanji_id)

    case Kanji
         |> Ash.Query.filter(id in ^kanji_ids)
         |> Ash.Query.load([:meanings, :pronunciations])
         |> Ash.read() do
      {:ok, kanji_list} ->
        # Combine progress records with kanji data
        combined = combine_progress_with_kanji(progress_records, kanji_list)
        {:ok, combined}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp combine_progress_with_kanji(progress_records, kanji_list) do
    kanji_map = Map.new(kanji_list, &{&1.id, &1})

    Enum.map(progress_records, fn progress ->
      kanji = Map.get(kanji_map, progress.kanji_id)
      Map.put(progress, :kanji, kanji)
    end)
  end

  defp update_progress_with_retry(progress, result, retries_left) when retries_left > 0 do
    case progress
         |> Ash.Changeset.for_update(:record_review, %{last_result: result})
         |> Ash.update() do
      {:ok, updated_progress} ->
        {:ok, updated_progress}

      {:error, %Ash.Error.Invalid{} = error} ->
        # Check if it's a concurrency error and retry
        if is_concurrency_error?(error) and retries_left > 1 do
          # Short delay before retry
          :timer.sleep(50)
          update_progress_with_retry(progress, result, retries_left - 1)
        else
          {:error, error}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp update_progress_with_retry(_progress, _result, 0) do
    {:error, :max_retries_exceeded}
  end

  defp is_concurrency_error?(%Ash.Error.Invalid{errors: errors}) do
    Enum.any?(errors, fn error ->
      case error do
        %Ash.Error.Changes.StaleRecord{} -> true
        _ -> false
      end
    end)
  end

  defp parse_naive_date(val) do
    cond do
      is_nil(val) ->
        nil

      is_struct(val, NaiveDateTime) ->
        val

      is_struct(val, DateTime) ->
        DateTime.to_naive(val)

      is_binary(val) ->
        # Remove trailing Z if present
        date_str = if String.ends_with?(val, "Z"), do: String.trim_trailing(val, "Z"), else: val

        case NaiveDateTime.from_iso8601(date_str) do
          {:ok, naive, _} -> naive
          {:ok, naive} -> naive
          _ -> nil
        end

      true ->
        nil
    end
  end

  defp calculate_user_stats(progress_records) do
    now = DateTime.utc_now()

    total_kanji = length(progress_records)

    due_today =
      progress_records
      |> Enum.count(fn record ->
        review_date = parse_naive_date(record.next_review_date)
        review_date && NaiveDateTime.compare(review_date, DateTime.to_naive(now)) != :gt
      end)

    {total_reviews, correct_reviews} =
      progress_records
      |> Enum.reduce({0, 0}, fn record, {total_acc, correct_acc} ->
        {total_acc + record.total_reviews, correct_acc + record.correct_reviews}
      end)

    accuracy = if total_reviews > 0, do: correct_reviews / total_reviews * 100, else: 0.0

    %{
      total_kanji: total_kanji,
      due_today: due_today,
      total_reviews: total_reviews,
      correct_reviews: correct_reviews,
      accuracy: Float.round(accuracy, 1)
    }
  end

  defp process_batch(user_id, kanji_ids) do
    require Logger

    Logger.debug("[SRS.Logic] Processing batch of #{length(kanji_ids)} kanji")

    try do
      results =
        Enum.map(kanji_ids, fn kanji_id ->
          # Add more detailed logging for debugging
          result = initialize_progress(user_id, kanji_id)
          Logger.debug("[SRS.Logic] Initialized kanji #{kanji_id}: #{inspect(result)}")
          result
        end)

      # Check if all succeeded
      if Enum.all?(results, &match?({:ok, _}, &1)) do
        success_results = Enum.map(results, fn {:ok, result} -> result end)
        {:ok, success_results}
      else
        # Find first error
        error_result = Enum.find(results, &match?({:error, _}, &1))
        Logger.error("[SRS.Logic] Error in batch processing: #{inspect(error_result)}")
        error_result
      end
    rescue
      e ->
        Logger.error(
          "[SRS.Logic] Exception in process_batch: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
        )

        {:error, :exception, e}
    end
  end

  @doc """
  Handles migration scenarios when kanji dataset is updated.

  This function addresses cases where:
  - Kanji are removed from the dataset
  - Kanji IDs change
  - New kanji are added

  ## Parameters
  - user_id: UUID of the user
  - options: Keyword list with migration options
    - :remove_orphaned - Remove progress for non-existent kanji (default: true)
    - :notify_user - Send notification about changes (default: false)

  ## Returns
  {:ok, %{removed: integer, updated: integer}} | {:error, reason}
  """
  def migrate_user_progress(user_id, options \\ []) when is_binary(user_id) do
    remove_orphaned = Keyword.get(options, :remove_orphaned, true)
    notify_user = Keyword.get(options, :notify_user, false)

    case UserKanjiProgress
         |> Ash.Query.for_read(:user_stats, %{user_id: user_id})
         |> Ash.read() do
      {:ok, progress_records} ->
        # Get all current kanji IDs
        current_kanji_ids = get_all_kanji_ids()

        # Find orphaned progress records
        orphaned_records =
          Enum.filter(progress_records, fn record ->
            record.kanji_id not in current_kanji_ids
          end)

        removed_count =
          if remove_orphaned do
            remove_orphaned_progress(orphaned_records)
          else
            0
          end

        if notify_user and removed_count > 0 do
          # In a real application, this would send a notification
          # For now, we'll log it
          require Logger
          Logger.info("Removed #{removed_count} orphaned progress records for user #{user_id}")
        end

        {:ok, %{removed: removed_count, updated: 0}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_all_kanji_ids do
    case Kanji
         |> Ash.Query.select([:id])
         |> Ash.read() do
      {:ok, kanji_list} -> Enum.map(kanji_list, & &1.id)
      {:error, _} -> []
    end
  end

  defp remove_orphaned_progress(orphaned_records) do
    Enum.reduce(orphaned_records, 0, fn record, count ->
      case Ash.destroy(record) do
        :ok -> count + 1
        {:error, _} -> count
      end
    end)
  end
end
