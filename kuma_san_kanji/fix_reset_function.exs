#!/usr/bin/env elixir

# Script to fix the reset_user_progress function in KumaSanKanji.SRS.Logic
# Run this with: mix run fix_reset_function.exs

defmodule FixResetFunction do
  def run do
    file_path = Path.join(["lib", "kuma_san_kanji", "srs", "logic.ex"])

    content = File.read!(file_path)
    fixed_content = fix_reset_user_progress(content)

    # Create backup
    backup_path = file_path <> ".bak"
    File.write!(backup_path, content)

    # Write fixed file
    File.write!(file_path, fixed_content)

    IO.puts("Fixed reset_user_progress function in #{file_path}")
    IO.puts("Original file backed up to #{backup_path}")
  end

  def fix_reset_user_progress(content) do
    # Find the start of the function definition
    function_pattern =
      ~r/def reset_user_progress\(user_id, options \\\\ \[\]\) when is_binary\(user_id\) do/

    function_match = Regex.run(function_pattern, content)

    if function_match do
      function_start = hd(function_match)

      # Split at function start to preserve everything before it
      [before_function, function_and_after] = String.split(content, function_start, parts: 2)

      # The fixed function
      fixed_function = """
      def reset_user_progress(user_id, options \\\\ []) when is_binary(user_id) do
        if Mix.env() == :dev do
          require Logger
          import Ash.Query
          
          # Get the number of kanji to initialize
          limit = Keyword.get(options, :limit, 10)
          # The immediate option is no longer needed as records are created with immediate due dates by default
          make_immediate = Keyword.get(options, :immediate, true)

          Logger.debug("[SRS.Logic] Resetting progress for user \#{user_id} (limit: \#{limit}, immediate: \#{make_immediate})")
          
          # Step 1: Delete all UserKanjiProgress records for this user - with detailed error handling
          delete_result = try do
            case UserKanjiProgress |> filter(user_id == ^user_id) |> Ash.read() do
              {:ok, progress_records} when is_list(progress_records) and length(progress_records) > 0 ->
                Logger.debug("[SRS.Logic] Found \#{length(progress_records)} existing progress records to delete")
                
                results = Enum.map(progress_records, fn record ->
                  # Create a proper destroy changeset using the record itself
                  Logger.debug("[SRS.Logic] Deleting record ID: \#{record.id}")
                  Ash.Changeset.for_destroy(record, :destroy) |> Ash.destroy()
                end)
                errors = Enum.filter(results, &match?({:error, _}, &1))
                
                if errors == [] do
                  {:ok, length(progress_records)}
                else
                  Logger.error("[SRS.Logic] Errors when deleting progress: \#{inspect(errors)}")
                  {:error, errors}
                end
              
              {:ok, []} ->
                # No progress records found, which is fine - just continue with initialization
                Logger.debug("[SRS.Logic] No existing progress records found for user \#{user_id}")
                {:ok, 0}
                
              {:error, %Ash.Error.Query.NotFound{} = error} ->
                # Not found is also fine - just continue with initialization
                Logger.debug("[SRS.Logic] No progress records table found for user \#{user_id}: \#{inspect(error)}")
                {:ok, 0}
                
              {:error, reason} ->
                Logger.error("[SRS.Logic] Failed to read progress records: \#{inspect(reason)}")
                {:error, reason}
            end
          rescue
            e ->
              Logger.error("[SRS.Logic] Exception in delete operation: \#{inspect(e)}\\n\#{Exception.format_stacktrace(__STACKTRACE__)}")
              {:error, :exception, e}
          end

          # Step 2: Create new progress for a few kanji with immediate due date
          case delete_result do
            {:ok, cleared_count} ->
              # Get kanji IDs for initialization
              Logger.debug("[SRS.Logic] Finding \#{limit} kanji for initialization...")
              
              try do
                kanji_ids_result = Kanji
                  |> Ash.Query.select([:id, :character, :grade])
                  |> Ash.Query.sort(grade: :asc)  # Start with easier kanji first
                  |> Ash.Query.limit(limit)
                  |> Ash.read()

                case kanji_ids_result do
                  {:ok, kanji_list} when is_list(kanji_list) and length(kanji_list) > 0 ->
                    kanji_ids = Enum.map(kanji_list, & &1.id)
                    kanji_chars = Enum.map_join(kanji_list, ", ", & &1.character)
                    
                    Logger.debug("[SRS.Logic] Initializing progress for kanji: \#{kanji_chars}")
                    
                    # Initialize progress for these kanji
                    try do
                      Logger.debug("[SRS.Logic] Calling bulk_initialize_progress with \#{length(kanji_ids)} kanji IDs")
                      init_result = bulk_initialize_progress(user_id, kanji_ids)
                      
                      case init_result do
                        {:ok, initialized_progress} when is_list(initialized_progress) and length(initialized_progress) > 0 ->
                          # The progress records are already initialized with the current date as next_review_date
                          # so we don't need to update them separately
                          Logger.debug("[SRS.Logic] Successfully reset progress. Cleared: \#{cleared_count}, Initialized: \#{length(initialized_progress)}")
                          {:ok, %{cleared: cleared_count, initialized: length(initialized_progress)}}
                        
                        {:ok, []} ->
                          Logger.error("[SRS.Logic] No progress records were created during initialization")
                          {:error, :no_progress_created}
                          
                        {:error, init_error} ->
                          Logger.error("[SRS.Logic] Failed to initialize progress: \#{inspect(init_error)}")
                          {:error, init_error}
                      end
                    rescue
                      e ->
                        Logger.error("[SRS.Logic] Exception in bulk_initialize_progress: \#{inspect(e)}\\n\#{Exception.format_stacktrace(__STACKTRACE__)}")
                        {:error, :exception, e}
                    end
                    
                  {:ok, []} ->
                    Logger.error("[SRS.Logic] No kanji found for initialization")
                    {:error, :no_kanji_available}
                    
                  {:error, kanji_error} ->
                    Logger.error("[SRS.Logic] Failed to get kanji for initialization: \#{inspect(kanji_error)}")
                    {:error, kanji_error}
                end
              rescue 
                e ->
                  Logger.error("[SRS.Logic] Exception finding kanji: \#{inspect(e)}\\n\#{Exception.format_stacktrace(__STACKTRACE__)}")
                  {:error, :exception, e}
              end
              
            {:error, reason} ->
              Logger.error("[SRS.Logic] Error during progress reset: \#{inspect(reason)}")
              {:error, reason}
          end
        else
          {:error, :not_allowed}
        end
      end
      """

      # Find the end of the function to determine what to keep after it
      # This is a simplified approach - in a real situation, you might need a more 
      # sophisticated technique to find the end of the function

      # Look for the next function definition or the end of the file
      next_function_pattern = ~r/\n\s*def\s+[a-z_]+/
      next_function_match = Regex.run(next_function_pattern, function_and_after)

      if next_function_match do
        next_function_start = hd(next_function_match)
        [_, after_function] = String.split(function_and_after, next_function_start, parts: 2)
        before_function <> fixed_function <> "\n  " <> next_function_start <> after_function
      else
        # If no next function, just append to end of file
        before_function <> fixed_function
      end
    else
      IO.puts("Warning: Could not find reset_user_progress function")
      content
    end
  end
end

FixResetFunction.run()
