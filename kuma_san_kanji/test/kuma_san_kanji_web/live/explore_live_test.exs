defmodule KumaSanKanjiWeb.ExploreLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  @endpoint KumaSanKanjiWeb.Endpoint

  describe "ExploreLive functionality" do
    setup do
      # Create test kanji data
      kanji1 = KumaSanKanji.Domain.create_kanji!(%{
        character: "水",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })

      kanji2 = KumaSanKanji.Domain.create_kanji!(%{
        character: "火",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })

      %{kanji1: kanji1, kanji2: kanji2}
    end

    test "displays kanji", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")

      # Check that it's the correct LiveView module
      assert view.module == KumaSanKanjiWeb.ExploreLive

      # Verify that some kanji character is displayed
      assert has_element?(view, ".kanji-display")
    end

    test "cycles through kanji on 'new_kanji' event", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")

      # Get initial kanji character
      initial_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()
      assert initial_kanji != nil

      # Click for next Kanji
      view |> element("button", "Show New Kanji") |> render_click()
      next_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()

      # The next kanji should be different from the initial one
      # Note: This test doesn't rely on specific characters, just that they change
      assert next_kanji != nil
      refute next_kanji == initial_kanji
    end

    # Helper function to extract kanji character from HTML
    defp extract_kanji_character(html) do
      ~r/<span[^>]*>([^<]+)<\/span>/
      |> Regex.run(html)
      |> case do
        [_, character] -> character
        _ -> nil
      end
    end

    # Test for no data case removed as it's difficult to set up in an environment
    # where the database is seeded and has foreign key constraints
  end
end
