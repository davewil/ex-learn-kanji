defmodule KumaSanKanjiWeb.QuizLive do
  @moduledoc """
  LiveView for the SRS-based kanji quiz system.

  Features:
  - Secure, authenticated quiz sessions
  - SM-2 spaced repetition algorithm
  - Accessible UI with ARIA labels and keyboard navigation
  - Real-time feedback and progress tracking
  - Rate limiting and input validation
  """
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.Quiz.Session

  # Rate limiting: max 100 answers per 5 minutes per user
  # 5 minutes in milliseconds
  @rate_limit_window 300_000
  @rate_limit_max_answers 100

  # Authentication required for this LiveView
  on_mount {KumaSanKanjiWeb.UserLiveAuth, :ensure_authenticated}

  @impl true
  def mount(params, _session_token, socket) do
    require Logger
    user = socket.assigns.current_user

    # Check for existing session to resume
    quiz_state =
      case restore_session_if_exists(user.id, params["session_id"]) do
        {:ok, restored_state} ->
          restored_state

        {:error, :no_session_id} ->
          # No session_id provided - this is normal for new sessions, not an error
          # Initialize new session
          case initialize_quiz_session(user.id) do
            {:ok, new_state} ->
              new_state

            {:error, reason} ->
              Logger.error(
                "[QuizLive] Failed to initialize quiz session for user #{user.id}: #{inspect(reason)}"
              )

              {:error, reason}
          end

        {:error, reason} ->
          # Log actual session restoration errors
          Logger.error(
            "[QuizLive] Failed to restore session for user #{user.id} with session_id #{params["session_id"]}: #{inspect(reason)}"
          )

          # Initialize new session as fallback
          case initialize_quiz_session(user.id) do
            {:ok, new_state} ->
              new_state

            {:error, reason2} ->
              Logger.error(
                "[QuizLive] Failed to initialize quiz session for user #{user.id}: #{inspect(reason2)}"
              )

              {:error, reason2}
          end
      end

    case quiz_state do
      {:error, reason} ->
        Logger.error("[QuizLive] Quiz state error for user #{user.id}: #{inspect(reason)}")

        socket =
          socket
          |> put_flash(:error, get_error_message(reason) <> " (debug: #{inspect(reason)})")
          |> assign(:quiz_error, true)
          |> assign(:keyboard_shortcuts_visible, false)
          |> assign(:dev_mode, Mix.env() == :dev)

        {:ok, socket}

      quiz_state when is_map(quiz_state) ->
        socket =
          socket
          |> assign(quiz_state)
          |> assign(:user_answer, "")
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:session_start_time, System.system_time(:millisecond))
          |> assign(:answers_count, quiz_state[:answers_count] || 0)
          |> assign(:last_answer_times, quiz_state[:last_answer_times] || [])
          |> assign(:quiz_complete, false)
          |> assign(:keyboard_shortcuts_visible, false)
          |> assign(:dev_mode, Mix.env() == :dev)

        {:ok, socket}
    end
  end

  @impl true
  def handle_event("submit_answer", %{"answer" => answer}, socket) do
    user = socket.assigns.current_user
    current_kanji = socket.assigns.current_kanji
    current_progress = socket.assigns.current_progress

    # Rate limiting check
    case check_rate_limit(socket) do
      :ok ->
        # Validate and sanitize user input
        case validate_and_sanitize_answer(answer) do
          {:ok, sanitized_answer} ->
            process_answer(socket, user, current_kanji, current_progress, sanitized_answer)

          {:error, reason} ->
            socket =
              socket
              |> assign(:show_feedback, true)
              |> assign(:feedback_message, get_validation_error_message(reason))
              |> assign(:feedback_type, :error)

            {:noreply, socket}
        end

      {:error, :rate_limited} ->
        socket =
          socket
          |> put_flash(:error, "Too many answers submitted. Please wait before continuing.")
          |> assign(:show_feedback, true)
          |> assign(
            :feedback_message,
            "Rate limit exceeded. Please wait before submitting more answers."
          )
          |> assign(:feedback_type, :warning)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("skip_kanji", _params, socket) do
    user = socket.assigns.current_user
    current_progress = socket.assigns.current_progress

    case Logic.record_review(current_progress.id, :skip, user.id) do
      {:ok, _updated_progress} ->
        load_next_kanji(socket)

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to skip kanji: #{get_error_message(reason)}")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("next_kanji", _params, socket) do
    load_next_kanji(socket)
  end

  @impl true
  def handle_event("toggle_keyboard_shortcuts", _params, socket) do
    {:noreply,
     assign(socket, :keyboard_shortcuts_visible, !socket.assigns.keyboard_shortcuts_visible)}
  end

  @impl true
  def handle_event("restart_quiz", _params, socket) do
    user = socket.assigns.current_user

    case initialize_quiz_session(user.id) do
      {:ok, quiz_state} ->
        socket =
          socket
          |> assign(quiz_state)
          |> assign(:user_answer, "")
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:quiz_complete, false)
          |> assign(:answers_count, 0)
          |> assign(:last_answer_times, [])

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, get_error_message(reason))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("reset_progress", _params, socket) do
    require Logger

    if Mix.env() == :dev do
      user = socket.assigns.current_user

      # Add detailed error handling with try/rescue
      try do
        # Use enhanced reset options - 15 kanji that are all due immediately
        case Logic.reset_user_progress(user.id, limit: 15, immediate: true) do
          {:ok, result} ->
            Logger.debug(
              "[QuizLive] Reset progress: cleared #{result.cleared} records, initialized #{result.initialized} kanji"
            )

            # Re-initialize the quiz session after reset
            case initialize_quiz_session(user.id) do
              {:ok, quiz_state} ->
                socket =
                  socket
                  |> assign(quiz_state)
                  |> assign(:user_answer, "")
                  |> assign(:show_feedback, false)
                  |> assign(
                    :feedback_message,
                    "Progress reset! #{result.initialized} kanji ready for review."
                  )
                  |> assign(:feedback_type, :info)
                  |> assign(:quiz_complete, false)
                  |> assign(:answers_count, 0)
                  |> assign(:last_answer_times, [])
                  |> put_flash(
                    :info,
                    "Quiz progress reset. #{result.initialized} kanji ready for immediate review."
                  )

                {:noreply, socket}

              {:error, reason} ->
                {:noreply,
                 put_flash(
                   socket,
                   :error,
                   "Failed to re-initialize quiz: #{get_error_message(reason)}"
                 )}
            end

          {:error, reason} ->
            Logger.error("[QuizLive] Failed to reset progress: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Failed to reset progress: #{inspect(reason)}")}
        end
      rescue
        e ->
          Logger.error(
            "[QuizLive] Exception in reset_progress: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
          )

          {:noreply, put_flash(socket, :error, "Error: #{Exception.message(e)}")}
      end
    else
      {:noreply, socket}
    end
  end

  # Keyboard event handling
  @impl true
  def handle_event("key_down", %{"key" => "Enter"}, socket) do
    if socket.assigns.show_feedback do
      handle_event("next_kanji", %{}, socket)
    else
      # Submit current answer
      answer = socket.assigns.user_answer
      handle_event("submit_answer", %{"answer" => answer}, socket)
    end
  end

  def handle_event("key_down", %{"key" => "Escape"}, socket) do
    handle_event("skip_kanji", %{}, socket)
  end

  def handle_event("key_down", %{"key" => "?"}, socket) do
    handle_event("toggle_keyboard_shortcuts", %{}, socket)
  end

  def handle_event("key_down", _params, socket) do
    {:noreply, socket}
  end

  # Direct key event handlers for test framework compatibility
  def handle_event("Escape", _params, socket) do
    handle_event("key_down", %{"key" => "Escape"}, socket)
  end

  def handle_event("Enter", _params, socket) do
    handle_event("key_down", %{"key" => "Enter"}, socket)
  end

  @impl true
  def handle_event("update_answer", %{"answer" => answer}, socket) do
    {:noreply, assign(socket, :user_answer, answer)}
  end

  # Handle test messages
  @impl true
  def handle_info({:set_last_answer_times, times}, socket) do
    {:noreply, assign(socket, :last_answer_times, times)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  # Private helper functions

  defp restore_session_if_exists(_user_id, nil), do: {:error, :no_session_id}

  defp restore_session_if_exists(user_id, session_id) do
    require Logger

    try do
      case Session.restore_for_user(user_id, session_id) do
        {:ok, session_data} ->
          # Get user stats to include with restored session
          case Logic.get_user_stats(user_id) do
            # Get progress for the current kanji if available
            {:ok, stats} ->
              current_progress =
                case session_data.current_kanji do
                  nil ->
                    nil

                  kanji ->
                    # Try to get the progress for this kanji
                    case Logic.get_due_kanji(user_id, 1) do
                      {:ok, [progress | _]} when progress.kanji.id == kanji.id -> progress
                      {:ok, _} -> nil
                      {:error, _} -> nil
                    end
                end

              {:ok,
               %{
                 current_kanji: session_data.current_kanji,
                 current_progress: current_progress,
                 user_stats: stats,
                 quiz_error: false,
                 answers_count: session_data.answers_count || 0,
                 last_answer_times: session_data.last_answer_times || []
               }}

            {:error, reason} ->
              {:error, reason}
          end

        {:error, _reason} ->
          {:error, :session_not_found}
      end
    rescue
      e ->
        Logger.error(
          "[QuizLive] Exception in restore_session_if_exists for user #{user_id}, session_id #{inspect(session_id)}: #{Exception.message(e)}\n" <>
            Exception.format(:error, e, __STACKTRACE__)
        )

        {:error, {:exception, Exception.message(e)}}
    end
  end

  defp save_session_state(socket, user_id) do
    current_kanji_id =
      case socket.assigns.current_kanji do
        nil -> nil
        kanji -> kanji.id
      end

    # Include both the kanji and progress data in the session
    session_data = %{
      user_id: user_id,
      current_kanji_id: current_kanji_id,
      current_kanji: socket.assigns.current_kanji,
      current_progress: socket.assigns.current_progress,
      answers_count: socket.assigns.answers_count,
      last_answer_times: socket.assigns.last_answer_times
    }

    # Save session asynchronously to avoid blocking the LiveView
    Task.start(fn ->
      case Session.save(session_data) do
        {:ok, _session_id} ->
          :ok

        {:error, reason} ->
          # Log error but don't interrupt the quiz flow
          require Logger
          Logger.warning("Failed to save quiz session: #{inspect(reason)}")
      end
    end)
  end

  # Private helper functions
  defp initialize_quiz_session(user_id) do
    require Logger

    try do
      # For new users, stats may not exist yet - that's expected
      stats_result = Logic.get_user_stats(user_id)

      stats =
        case stats_result do
          {:ok, stats} -> stats
          # New user without stats
          {:error, _} -> %{}
        end

      # Check for due kanji
      case Logic.get_due_kanji(user_id, 1) do
        {:ok, [progress | _]} ->
          # Keep both the progress record and extract kanji for easy access
          kanji = progress.kanji

          {:ok,
           %{
             current_kanji: kanji,
             current_progress: progress,
             user_stats: stats,
             quiz_error: false
           }}

        {:ok, []} ->
          # No kanji are due - this is an expected state, not an error
          {:ok,
           %{
             current_kanji: nil,
             user_stats: stats,
             quiz_error: false
           }}

        {:error, reason} ->
          # Only propagate errors from get_due_kanji if they're not related to empty stats
          case reason do
            :not_found -> {:ok, %{current_kanji: nil, user_stats: stats, quiz_error: false}}
            _ -> {:error, reason}
          end
      end
    rescue
      e ->
        Logger.error(
          "[QuizLive] Exception in initialize_quiz_session for user #{user_id}: #{Exception.message(e)}\n" <>
            Exception.format(:error, e, __STACKTRACE__)
        )

        {:error, {:exception, Exception.message(e)}}
    end
  end

  defp validate_and_sanitize_answer(answer) when is_binary(answer) do
    # Basic validation and sanitization
    trimmed = String.trim(answer)

    cond do
      String.length(trimmed) == 0 ->
        {:error, :empty_answer}

      String.length(trimmed) > 100 ->
        {:error, :answer_too_long}

      !String.match?(trimmed, ~r/^[\p{L}\p{N}\p{P}\s]+$/u) ->
        {:error, :invalid_characters}

      true ->
        # HTML escape for XSS prevention
        sanitized = Phoenix.HTML.html_escape(trimmed) |> Phoenix.HTML.safe_to_string()
        {:ok, sanitized}
    end
  end

  defp validate_and_sanitize_answer(_), do: {:error, :invalid_format}

  defp check_rate_limit(socket) do
    current_time = System.system_time(:millisecond)
    _session_start = socket.assigns.session_start_time
    last_times = socket.assigns.last_answer_times

    # Remove old timestamps outside the window
    recent_times =
      Enum.filter(last_times, fn time ->
        current_time - time < @rate_limit_window
      end)

    if length(recent_times) >= @rate_limit_max_answers do
      {:error, :rate_limited}
    else
      :ok
    end
  end

  defp process_answer(socket, user, current_kanji, current_progress, sanitized_answer) do
    # Determine if answer is correct
    is_correct = check_answer_correctness(current_kanji, sanitized_answer)
    result = if is_correct, do: :correct, else: :incorrect

    case Logic.record_review(current_progress.id, result, user.id) do
      {:ok, _updated_progress} ->
        # Update rate limiting tracking
        current_time = System.system_time(:millisecond)
        updated_times = [current_time | socket.assigns.last_answer_times]

        socket =
          socket
          |> assign(:show_feedback, true)
          |> assign(:feedback_message, get_feedback_message(result, current_kanji))
          |> assign(:feedback_type, if(is_correct, do: :success, else: :error))
          |> assign(:user_answer, "")
          |> assign(:answers_count, socket.assigns.answers_count + 1)
          |> assign(:last_answer_times, updated_times)
          # Ensure current_kanji is still available for the "Next" button
          |> assign(:current_kanji, current_kanji)

        # Save session state after successful answer
        save_session_state(socket, user.id)

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to record answer: #{get_error_message(reason)}")

        {:noreply, socket}
    end
  end

  defp load_next_kanji(socket) do
    user = socket.assigns.current_user

    case Logic.get_due_kanji(user.id, 1) do
      {:ok, [progress | _]} ->
        # Extract kanji from progress record
        next_kanji = progress.kanji

        # Reset quiz state for next kanji
        socket =
          socket
          |> assign(:current_kanji, next_kanji)
          # Save the progress record
          |> assign(:current_progress, progress)
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:user_answer, "")
          |> assign(:quiz_complete, false)

        # Save session state for the new kanji
        save_session_state(socket, user.id)

        {:noreply, socket}

      {:ok, []} ->
        # No more kanji due for review
        socket =
          socket
          |> assign(:current_kanji, nil)
          # Clear the progress record
          |> assign(:current_progress, nil)
          |> assign(:quiz_complete, true)
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)

        # Save completion state
        save_session_state(socket, user.id)

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to load next kanji: #{get_error_message(reason)}")
          |> assign(:quiz_error, true)

        {:noreply, socket}
    end
  end

  defp check_answer_correctness(kanji, user_answer) do
    # Check if user answer matches any of the kanji's readings or meanings
    # The kanji may be the direct structure or nested within a progress record
    kanji_data = kanji

    normalized_answer = String.downcase(String.trim(user_answer))

    # Check meanings (from meanings relationship)
    meanings_match =
      kanji_data.meanings
      |> Enum.any?(fn meaning_record ->
        String.downcase(String.trim(meaning_record.value)) == normalized_answer
      end)

    # Check readings (from pronunciations relationship)
    readings_match =
      kanji_data.pronunciations
      |> Enum.any?(fn pronunciation_record ->
        String.downcase(String.trim(pronunciation_record.value)) == normalized_answer
      end)

    meanings_match || readings_match
  end

  defp get_feedback_message(:correct, kanji) do
    kanji_data = kanji
    meanings = kanji_data.meanings |> Enum.map(& &1.value) |> Enum.join(", ")
    readings = kanji_data.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")

    "Correct! #{kanji_data.character} means: #{meanings}. Readings: #{readings}"
  end

  defp get_feedback_message(:incorrect, kanji) do
    kanji_data = kanji
    meanings = kanji_data.meanings |> Enum.map(& &1.value) |> Enum.join(", ")
    readings = kanji_data.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")

    "Incorrect. #{kanji_data.character} means: #{meanings}. Readings: #{readings}"
  end

  # Helper to get a user-friendly error message
  # Only show debug info in non-prod environments
  defp get_error_message(reason) do
    case reason do
      :no_session_id -> "No quiz session found."
      {:exception, msg} -> "Quiz error: #{msg}"
      _ -> if Mix.env() == :prod, do: "Quiz Error", else: "Quiz Error (#{inspect(reason)})"
    end
  end

  defp get_validation_error_message(:empty_answer), do: "Please enter an answer"

  defp get_validation_error_message(:answer_too_long),
    do: "Answer is too long (max 100 characters)"

  defp get_validation_error_message(:invalid_characters), do: "Answer contains invalid characters"
  defp get_validation_error_message(:invalid_format), do: "Invalid answer format"
end
