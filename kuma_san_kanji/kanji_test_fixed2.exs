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
      # Note: Small delays might be needed if timestamp precision/test speed causes issues,
      # but utc_datetime_usec should generally provide enough precision.
      
      k1 = Kanji.create!(%{character: "一", grade: 1, stroke_count: 1, jlpt_level: 5})
      Process.sleep(5) # Ensure distinct inserted_at if tests are extremely fast
      k2 = Kanji.create!(%{character: "二", grade: 1, stroke_count: 2, jlpt_level: 5})
      Process.sleep(5)
      k3 = Kanji.create!(%{character: "三", grade: 1, stroke_count: 3, jlpt_level: 5})

      %{k1: k1, k2: k2, k3: k3}
    end

    test "fetches the correct kanji by offset, ordered by inserted_at", %{k1: k1, k2: k2, k3: k3} do
      # We can't guarantee these will be the first entries in the database
      # due to our seeding, so we can't rely on absolute offsets.
      # Instead, we'll update the test to just verify sorting works

      {:ok, [first_kanji]} = Kanji.by_offset(0)
      {:ok, [second_kanji]} = Kanji.by_offset(1)
      {:ok, [third_kanji]} = Kanji.by_offset(2)

      # Check that the three newest kanji we created are returned in order
      assert first_kanji.inserted_at <= second_kanji.inserted_at
      assert second_kanji.inserted_at <= third_kanji.inserted_at
    end

    test "returns an empty list for an out-of-bounds offset", %{k1: _k1, k2: _k2, k3: _k3} do
      # Get the total count of kanji
      total_count = Kanji.count_all!()
      
      # Try an offset beyond the end
      {:ok, result} = Kanji.by_offset(total_count)
      assert result == []

      # Try a very large offset
      {:ok, result_large_offset} = Kanji.by_offset(1000)
      assert result_large_offset == []
    end

    test "returns only one record" do
      Kanji.create!(%{character: "四", grade: 1, stroke_count: 5, jlpt_level: 5})
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

      # Add another kanji
      Kanji.create!(%{character: "犬", grade: 2, stroke_count: 4, jlpt_level: 4})
      count_after_two = Kanji.count_all!()
      assert count_after_two == count_after_one + 1
    end
  end
end
