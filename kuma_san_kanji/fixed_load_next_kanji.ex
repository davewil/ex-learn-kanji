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
