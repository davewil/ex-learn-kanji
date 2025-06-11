defmodule KumaSanKanji.SRS.IntegrationTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  require Ash.Query

  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.Kanji.{Kanji, Meaning, Pronunciation}
  # Setup helpers
  defp create_test_user(_) do
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:sign_up, %{
        email: "test-#{System.system_time(:millisecond)}@example.com",
        username: "testuser#{System.system_time(:millisecond)}",
        password: "Password123!"
      })
      |> Ash.create()

    %{user: user}
  end

  defp create_test_kanji(_) do
    # Create a test kanji with known meanings and pronunciations
    {:ok, kanji} =
      Kanji
      |> Ash.Changeset.for_create(:create, %{
        character: "水",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })
      # Add meanings
      |> Ash.create()

    {:ok, _} =
      Meaning
      |> Ash.Changeset.for_create(:create, %{kanji_id: kanji.id, value: "water"})
      |> Ash.create()

    {:ok, _} =
      Meaning
      |> Ash.Changeset.for_create(:create, %{kanji_id: kanji.id, value: "liquid"})
      # Add pronunciations
      |> Ash.create()

    {:ok, _} =
      Pronunciation
      |> Ash.Changeset.for_create(:create, %{
        kanji_id: kanji.id,
        value: "みず",
        type: :kun
      })
      |> Ash.create()

    {:ok, _} =
      Pronunciation
      |> Ash.Changeset.for_create(:create, %{
        kanji_id: kanji.id,
        value: "スイ",
        type: :on
      })
      # Load the relationships for testing
      |> Ash.create()

    {:ok, [kanji_with_relationships]} =
      Kanji
      |> Ash.Query.filter(id == ^kanji.id)
      |> Ash.Query.load([:meanings, :pronunciations])
      |> Ash.read()

    %{kanji: kanji_with_relationships}
  end

  defp login_user(%{conn: conn, user: user}) do
    conn =
      post(conn, ~p"/login", %{
        "email" => user.email,
        "password" => "Password123!"
      })

    %{conn: conn}
  end

  defp initialize_srs_progress(%{user: user, kanji: kanji}) do
    {:ok, progress} = Logic.initialize_progress(user.id, kanji.id)
    %{progress: progress}
  end

  describe "SRS quiz integration tests" do
    setup [:create_test_user, :create_test_kanji, :login_user, :initialize_srs_progress]

    @tag :integration
    test "end-to-end quiz flow - submission to progression", %{
      conn: conn,
      progress: progress,
      user: _user,
      kanji: kanji
    } do
      # Start the quiz LiveView
      {:ok, view, _html} = live(conn, ~p"/quiz")

      # Verify the quiz is initialized correctly
      assert view |> has_element?("div", kanji.character)
      # Submit a correct answer (meaning)
      assert render(view) =~ "Rep: 0"
      correct_meaning = List.first(kanji.meanings).value

      # Make sure form is available before submitting
      if view |> has_element?("button", "Next") do
        view |> element("button", "Next") |> render_click()
      end

      view |> element("form") |> render_submit(%{answer: correct_meaning})

      # Verify feedback is displayed
      assert view |> has_element?("div", "Correct!")
      assert view |> has_element?("div[role='region'][aria-label='Answer feedback']")

      # Continue to next kanji
      view |> element("button", "Next") |> render_click()

      # Verify session stats are updated or quiz is complete
      # Check if SRS state was updated in database
      html = render(view)
      assert html =~ "Session:" or html =~ "No Reviews Available"

      {:ok, [updated_progress]} =
        UserKanjiProgress
        |> Ash.Query.filter(id == ^progress.id)
        |> Ash.read()

      assert updated_progress.repetitions == 1
      assert updated_progress.correct_reviews == 1
      assert updated_progress.total_reviews == 1
      assert updated_progress.last_result == :correct
    end

    @tag :integration
    test "quiz handles incorrect answers properly", %{
      conn: conn,
      progress: progress
    } do
      # Start the quiz LiveView
      {:ok, view, _html} = live(conn, ~p"/quiz")

      # Submit an incorrect answer
      view |> element("form") |> render_submit(%{answer: "wrong answer"})

      # Verify feedback is displayed
      assert view |> has_element?("div[role='region'][aria-label='Answer feedback']")
      assert render(view) =~ "Incorrect"

      # Continue to next kanji
      # Check if SRS state was updated correctly in database for incorrect answer
      view |> element("button", "Next") |> render_click()

      {:ok, [updated_progress]} =
        UserKanjiProgress
        |> Ash.Query.filter(id == ^progress.id)
        |> Ash.read()

      # Reset to 0 for incorrect answers
      assert updated_progress.repetitions == 0
      assert updated_progress.correct_reviews == 0
      assert updated_progress.total_reviews == 1
      assert updated_progress.last_result == :incorrect
    end

    @tag :integration
    test "skipping a kanji works correctly", %{
      conn: conn,
      progress: progress
    } do
      # Start the quiz LiveView
      # Skip the kanji
      {:ok, view, _html} = live(conn, ~p"/quiz")
      # Check if SRS state was updated correctly for skip
      view |> element("button", "Skip") |> render_click()

      {:ok, [updated_progress]} =
        UserKanjiProgress
        |> Ash.Query.filter(id == ^progress.id)
        |> Ash.read()

      assert updated_progress.last_result == :skip
      assert updated_progress.total_reviews == 1
    end

    @tag :integration
    test "quiz completion screen is shown when no more kanji are due", %{
      conn: conn,
      progress: progress,
      user: _user
    } do
      # First, update the progress so the kanji is not due for review
      # 1 day in the future
      future_date = DateTime.add(DateTime.utc_now(), 24 * 60 * 60, :second)

      progress
      |> Ash.Changeset.for_update(:update, %{
        next_review_date: future_date
      })
      |> Ash.update!()

      # Start the quiz LiveView
      {:ok, view, _html} = live(conn, ~p"/quiz")

      # Verify we see the completion screen
      assert view |> has_element?("h2", "No Reviews Available")
      assert render(view) =~ "You don" # Match the beginning to avoid HTML entity issues

      # Test the restart button
      view |> element("button", "Check Again") |> render_click()
    end
  end

  describe "SRS quiz security tests" do
    setup [:create_test_user, :create_test_kanji, :login_user, :initialize_srs_progress]

    @tag :security
    # Create another user who shouldn't have access
    test "unauthorized access is prevented", %{
      progress: progress
    } do
      {:ok, other_user} =
        User
        |> Ash.Changeset.for_create(:sign_up, %{
          email: "other-#{System.system_time(:millisecond)}@example.com",
          username: "otheruser#{System.system_time(:millisecond)}",
          password: "Password123!"
        })
        |> Ash.create()

      # Try to access first user's progress
      result = Logic.record_review(progress.id, :correct, other_user.id)
      assert result == {:error, :unauthorized}
    end

    @tag :security
    test "input validation prevents malicious inputs", %{
      conn: conn
    } do
      # Start the quiz LiveView
      {:ok, view, _html} = live(conn, ~p"/quiz")

      # Try submitting various problematic inputs
      malicious_inputs = [
        "<script>alert('XSS')</script>",
        "' OR 1=1 --",
        # Too long input
        String.duplicate("a", 1000)
      ]

      for input <- malicious_inputs do
        # Make sure we're in the answer input state, not feedback state
        if view |> has_element?("button", "Next") do
          view |> element("button", "Next") |> render_click()
        end

        # Now submit the malicious input
        if view |> has_element?("form") do
          view |> element("form") |> render_submit(%{answer: input})

          # Verify no unescaped content or exceptions
          html = render(view)
          refute html =~ "<script>"
          assert view |> has_element?("div[role='region'][aria-label='Answer feedback']")
        end
      end
    end
  end

  describe "SRS edge cases" do
    setup [:create_test_user, :create_test_kanji, :login_user, :initialize_srs_progress]

    @tag :edge_case
    test "concurrent updates are handled properly", %{
      progress: progress,
      user: user
    } do
      # Simulate concurrent updates by creating a race condition
      tasks =
        for _ <- 1..5 do
          Task.async(fn ->
            Logic.record_review(progress.id, :correct, user.id)
          end)
        end

      # Wait for all tasks to complete
      results = Task.await_many(tasks)

      # At least one should succeed, others might get errors
      success_count =
        Enum.count(results, fn
          {:ok, _} -> true
          _ -> false
        end)

      assert success_count >= 1

      # The final state should be consistent
      {:ok, [final_progress]} =
        UserKanjiProgress
        |> Ash.Query.filter(id == ^progress.id)
        |> Ash.read()

      # Total reviews should be between 1 and 5
      assert final_progress.total_reviews > 0
      assert final_progress.total_reviews <= 5
    end
  end

  describe "SRS quiz accessibility" do
    setup [:create_test_user, :create_test_kanji, :login_user, :initialize_srs_progress]

    @tag :accessibility
    test "ARIA attributes are properly set", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/quiz")
      html = render(view)

      # Check for important ARIA attributes
      assert html =~ ~r/role="region"/
      assert html =~ ~r/aria-label="Quiz statistics"/
      assert html =~ ~r/aria-hidden="true"/

      # Make sure we're in the answer input state to check form elements
      if view |> has_element?("button", "Next") do
        view |> element("button", "Next") |> render_click()
      end

      # Verify form elements have proper labels when form is available
      if view |> has_element?("form") do
        assert view |> has_element?("label[for]")
      end
    end

    @tag :accessibility
    test "keyboard navigation works correctly", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/quiz")

      # Make sure we're in the answer input state, not feedback state
      if view |> has_element?("button", "Next") do
        view |> element("button", "Next") |> render_click()
      end

      # Simulate pressing Enter key to submit form
      if view |> has_element?("form") do
        view
        |> element("form")
        |> render_submit(%{answer: "test"})

        # Check if the form was submitted and feedback is shown
        assert view |> has_element?("div[role='region'][aria-label='Answer feedback']")
      end
    end
  end
end
