defmodule KumaSanKanjiWeb.QuizLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.Kanji.{Kanji, Meaning, Pronunciation}

  setup do
    # Create test user
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:register, %{
        email: "quiz-test-#{System.system_time(:millisecond)}@example.com",
        password: "Password123!",
        password_confirmation: "Password123!"
      })
      |> Ash.create()

    # Create test kanji
    {:ok, kanji} =
      Kanji
      |> Ash.Changeset.for_create(:create, %{
        character: "木",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })
      |> Ash.create()

    # Add meanings
    {:ok, _} =
      Meaning
      |> Ash.Changeset.for_create(:create, %{kanji_id: kanji.id, meaning: "tree"})
      |> Ash.create()

    # Add pronunciations
    {:ok, _} =
      Pronunciation
      |> Ash.Changeset.for_create(:create, %{
        kanji_id: kanji.id,
        value: "き",
        type: :kun
      })
      |> Ash.create()

    {:ok, _} =
      Pronunciation
      |> Ash.Changeset.for_create(:create, %{
        kanji_id: kanji.id,
        value: "モク",
        type: :on
      })
      |> Ash.create()

    # Initialize SRS progress
    {:ok, progress} = Logic.initialize_progress(user.id, kanji.id)

    # Login user
    conn =
      post(build_conn(), ~p"/users/log_in", %{
        "user" => %{"email" => user.email, "password" => "Password123!"}
      })

    {:ok, conn: conn, user: user, kanji: kanji, progress: progress}
  end

  describe "Quiz LiveView" do
    test "mounts correctly and displays the quiz", %{conn: conn, kanji: kanji} do
      {:ok, view, html} = live(conn, ~p"/quiz")

      assert html =~ "Kanji Review Quiz"
      assert html =~ kanji.character
    end

    test "displays correct user stats", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/quiz")

      assert render(view) =~ "Total: 1"
      assert render(view) =~ "Due: 1"
      # Initially 0% accuracy
      assert render(view) =~ "Accuracy: 0.0%"
    end

    test "handles rate limiting", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Set a very high number of recent answers to trigger rate limiting
      send(view.pid, {:set_last_answer_times, List.duplicate(System.system_time(:millisecond), 101)})

      # Try submitting an answer
      view |> element("form") |> render_submit(%{answer: "test"})

      # Verify rate limit message
      assert render(view) =~ "Rate limit exceeded"
    end
  end

  describe "Quiz LiveView keyboard shortcuts" do
    test "toggles keyboard shortcuts panel", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Initially, keyboard shortcuts should be hidden
      refute render(view) =~ "Keyboard Shortcuts"

      # Click the button to show keyboard shortcuts
      view |> element("button[aria-label='Show keyboard shortcuts']") |> render_click()

      # Now keyboard shortcuts should be visible
      assert render(view) =~ "Keyboard Shortcuts"

      # Click again to hide
      view |> element("button[aria-label='Hide keyboard shortcuts']") |> render_click()

      # Should be hidden again
      refute render(view) =~ "Keyboard Shortcuts"
    end

    test "Enter key submits the form", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Fill the answer field
      view 
      |> element("form") 
      |> render_change(%{answer: "tree"})

      # Press Enter key
      view 
      |> element("form") 
      |> render_keydown(%{key: "Enter"})

      # Should show feedback
      assert view |> has_element?("div[role='region'][aria-label='Answer feedback']")
      assert render(view) =~ "Correct!"
    end

    test "Escape key closes feedback", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Submit an answer to show feedback
      view |> element("form") |> render_submit(%{answer: "tree"})
      assert render(view) =~ "Correct!"

      # Press Escape key
      render_keydown(view, %{key: "Escape"})

      # Feedback should be hidden and next kanji shown
      refute view |> has_element?("div[role='region'][aria-label='Answer feedback']")
    end
  end

  describe "Quiz LiveView error handling" do
    test "displays friendly error messages for invalid inputs", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Test with empty answer
      view |> element("form") |> render_submit(%{answer: ""})
      assert render(view) =~ "Please enter an answer"

      # Test with extremely long answer
      view |> element("form") |> render_submit(%{answer: String.duplicate("a", 200)})
      assert render(view) =~ "Answer is too long"
    end

    test "handles server errors gracefully", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Simulate a server error
      send(view.pid, {:simulate_error, :server_error})

      # Try to submit an answer
      view |> element("form") |> render_submit(%{answer: "test"})

      # Should show an error message
      assert render(view) =~ "An unexpected error occurred"
    end
  end

  describe "Quiz LiveView accessibility" do
    test "has proper ARIA attributes", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/quiz")

      # Check for important accessibility elements
      assert html =~ ~r/role="region"/
      assert html =~ ~r/aria-label="Quiz statistics"/
      assert html =~ ~r/aria-hidden="true"/
      assert html =~ ~r/<label for=/
      assert html =~ ~r/aria-live="polite"/
    end

    test "has proper heading structure", %{conn: conn} do
      {:ok, view, _} = live(conn, ~p"/quiz")

      # Verify proper h1, h2 structure
      assert view |> has_element?("h1", "Kanji Review Quiz")
      assert view |> has_element?("h2")
    end
  end
end
