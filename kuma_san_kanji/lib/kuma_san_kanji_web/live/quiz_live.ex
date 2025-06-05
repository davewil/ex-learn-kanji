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
  alias Phoenix.LiveView.JS
  
  # Rate limiting: max 100 answers per 5 minutes per user
  @rate_limit_window 300_000  # 5 minutes in milliseconds
  @rate_limit_max_answers 100
  
  # Authentication required for this LiveView
  on_mount {KumaSanKanjiWeb.UserLiveAuth, :ensure_authenticated}

  @impl true
  def mount(_params, _session, socket) do
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
          |> assign(:session_start_time, System.system_time(:millisecond))
          |> assign(:answers_count, 0)
          |> assign(:last_answer_times, [])
          |> assign(:quiz_complete, false)
          |> assign(:keyboard_shortcuts_visible, false)
        
        {:ok, socket}
      
      {:error, reason} ->
        socket = 
          socket
          |> put_flash(:error, get_error_message(reason))
          |> assign(:quiz_error, true)
        
        {:ok, socket}
    end
  end

  @impl true
  def handle_event("submit_answer", %{"answer" => answer}, socket) do
    user = socket.assigns.current_user
    current_kanji = socket.assigns.current_kanji
    
    # Rate limiting check
    case check_rate_limit(socket) do
      :ok ->
        # Validate and sanitize user input
        case validate_and_sanitize_answer(answer) do
          {:ok, sanitized_answer} ->
            process_answer(socket, user, current_kanji, sanitized_answer)
          
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
          |> assign(:feedback_message, "Rate limit exceeded. Please wait before submitting more answers.")
          |> assign(:feedback_type, :warning)
        
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("skip_kanji", _params, socket) do
    user = socket.assigns.current_user
    current_kanji = socket.assigns.current_kanji
    
    case Logic.record_review(current_kanji.id, :skip, user.id) do
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
    {:noreply, assign(socket, :keyboard_shortcuts_visible, !socket.assigns.keyboard_shortcuts_visible)}
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

  @impl true
  def handle_event("update_answer", %{"answer" => answer}, socket) do
    {:noreply, assign(socket, :user_answer, answer)}
  end

  # Private helper functions

  defp initialize_quiz_session(user_id) do
    with {:ok, due_kanji} <- Logic.get_due_kanji(user_id, 1),
         {:ok, stats} <- Logic.get_user_stats(user_id) do
      
      case due_kanji do
        [kanji | _] ->
          {:ok, %{
            current_kanji: kanji,
            user_stats: stats,
            quiz_error: false
          }}
        
        [] ->
          {:ok, %{
            current_kanji: nil,
            user_stats: stats,
            quiz_error: false
          }}
      end
    else
      {:error, reason} -> {:error, reason}
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
    recent_times = Enum.filter(last_times, fn time ->
      current_time - time < @rate_limit_window
    end)
    
    if length(recent_times) >= @rate_limit_max_answers do
      {:error, :rate_limited}
    else
      :ok
    end
  end

  defp process_answer(socket, user, current_kanji, sanitized_answer) do
    # Determine if answer is correct
    is_correct = check_answer_correctness(current_kanji, sanitized_answer)
    result = if is_correct, do: :correct, else: :incorrect
    
    case Logic.record_review(current_kanji.id, result, user.id) do
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
      {:ok, [next_kanji | _]} ->
        socket = 
          socket
          |> assign(:current_kanji, next_kanji)
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:user_answer, "")
        
        {:noreply, socket}
      
      {:ok, []} ->
        # No more kanji due for review
        socket = 
          socket
          |> assign(:quiz_complete, true)
          |> assign(:show_feedback, false)
        
        {:noreply, socket}
      
      {:error, reason} ->
        socket = 
          socket
          |> put_flash(:error, "Failed to load next kanji: #{get_error_message(reason)}")
        
        {:noreply, socket}
    end
  end
  defp check_answer_correctness(kanji, user_answer) do
    # Check if user answer matches any of the kanji's readings or meanings
    kanji_data = kanji.kanji
    
    normalized_answer = String.downcase(String.trim(user_answer))
    
    # Check meanings (from meanings relationship)
    meanings_match = kanji_data.meanings
    |> Enum.any?(fn meaning_record ->
      String.downcase(String.trim(meaning_record.meaning)) == normalized_answer
    end)
    
    # Check readings (from pronunciations relationship)
    readings_match = kanji_data.pronunciations
    |> Enum.any?(fn pronunciation_record ->
      String.downcase(String.trim(pronunciation_record.value)) == normalized_answer
    end)
    
    meanings_match || readings_match
  end
  defp get_feedback_message(:correct, kanji) do
    kanji_data = kanji.kanji
    meanings = kanji_data.meanings |> Enum.map(& &1.meaning) |> Enum.join(", ")
    readings = kanji_data.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")
    
    "Correct! #{kanji_data.character} means: #{meanings}. Readings: #{readings}"
  end

  defp get_feedback_message(:incorrect, kanji) do
    kanji_data = kanji.kanji
    meanings = kanji_data.meanings |> Enum.map(& &1.meaning) |> Enum.join(", ")
    readings = kanji_data.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")
    
    "Incorrect. #{kanji_data.character} means: #{meanings}. Readings: #{readings}"
  end

  defp get_error_message(:not_found), do: "Kanji not found"
  defp get_error_message(:kanji_not_found), do: "Kanji data not available"
  defp get_error_message(:too_many_kanji), do: "Too many kanji requested"
  defp get_error_message(_), do: "An unexpected error occurred"

  defp get_validation_error_message(:empty_answer), do: "Please enter an answer"
  defp get_validation_error_message(:answer_too_long), do: "Answer is too long (max 100 characters)"
  defp get_validation_error_message(:invalid_characters), do: "Answer contains invalid characters"
  defp get_validation_error_message(:invalid_format), do: "Invalid answer format"
  defp get_validation_error_message(_), do: "Invalid answer"
end
