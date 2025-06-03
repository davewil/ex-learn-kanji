defmodule KumaSanKanji.Kanji.KanjiTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Kanji.Kanji

  test "create action creates a kanji with timestamps" do
    params = %{character: "測", grade: 1, stroke_count: 10, jlpt_level: 1}
    {:ok, kanji} = Kanji.create(params)

    assert kanji.id
    assert kanji.character == "測"
    assert kanji.inserted_at
    assert kanji.updated_at
  end

  describe ":by_offset action" do
    setup do
      # Create kanji records sequentially. Their inserted_at timestamps should differ.
      # Note: We're adding new kanji on top of the seeded data, so we can't assume specific positions

      k1 = Kanji.create!(%{character: "一", grade: 1, stroke_count: 1, jlpt_level: 5})
      Process.sleep(5) # Ensure distinct inserted_at if tests are extremely fast
      k2 = Kanji.create!(%{character: "二", grade: 1, stroke_count: 2, jlpt_level: 5})
      Process.sleep(5)
      k3 = Kanji.create!(%{character: "三", grade: 1, stroke_count: 3, jlpt_level: 5})

      %{k1: k1, k2: k2, k3: k3}
    end

    test "fetches kanji in the correct relative order", %{k1: k1, k2: k2, k3: k3} do
      # Get the current total count
      total_count = Kanji.count_all!()

      # These tests assume the 3 kanji we created are at the end of the list
      # because they were inserted last

      {:ok, [fetched_k1]} = Kanji.by_offset(total_count - 3)
      assert fetched_k1.id == k1.id
      assert fetched_k1.character == "一"

      {:ok, [fetched_k2]} = Kanji.by_offset(total_count - 2)
      assert fetched_k2.id == k2.id
      assert fetched_k2.character == "二"

      {:ok, [fetched_k3]} = Kanji.by_offset(total_count - 1)
      assert fetched_k3.id == k3.id
      assert fetched_k3.character == "三"
    end

    test "returns an empty list for an out-of-bounds offset" do
      total_count = Kanji.count_all!()

      # Test with an offset that's definitely out of bounds
      {:ok, result} = Kanji.by_offset(total_count)
      assert result == []

      {:ok, result_large_offset} = Kanji.by_offset(total_count + 100)
      assert result_large_offset == []
    end

    test "returns only one record" do
      # Ensure a new kanji is created
      Kanji.create!(%{character: "四", grade: 1, stroke_count: 5, jlpt_level: 5})

      # Pick any valid offset, e.g. 0
      {:ok, result} = Kanji.by_offset(0)
      assert length(result) == 1
    end
  end

  describe ":count action (via count_all in code_interface)" do
    test "returns the correct count of kanji" do
      # Get initial count
      initial_count = Kanji.count_all!()

      # Add a new kanji
      Kanji.create!(%{character: "愛", grade: 4, stroke_count: 13, jlpt_level: 3})
      count_after_one = Kanji.count_all!()
      assert count_after_one == initial_count + 1

      Kanji.create!(%{character: "犬", grade: 2, stroke_count: 4, jlpt_level: 4})
      count_after_two = Kanji.count_all!()
      assert count_after_two == initial_count + 2
    end
  end
end
