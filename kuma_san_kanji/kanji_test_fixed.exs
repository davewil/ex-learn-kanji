defmodule KumaSanKanji.Kanji.KanjiTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Kanji.Kanji

  setup do
    # Clear all kanji before each test to ensure a clean state
    {:ok, kanjis} = Ash.read(Kanji)
    if kanjis && length(kanjis) > 0 do
      Enum.each(kanjis, fn kanji ->
        Ash.destroy!(kanji)
      end)
    end
    :ok
  end

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
      
      # Clear existing kanji first to ensure predictable offsets
      {:ok, kanjis} = Ash.read(Kanji)
      if kanjis && length(kanjis) > 0 do
        Enum.each(kanjis, fn kanji ->
          Ash.destroy!(kanji)
        end)
      end
        
      k1 = Kanji.create!(%{character: "一", grade: 1, stroke_count: 1, jlpt_level: 5})
      Process.sleep(5) # Ensure distinct inserted_at if tests are extremely fast
      k2 = Kanji.create!(%{character: "二", grade: 1, stroke_count: 2, jlpt_level: 5})
      Process.sleep(5)
      k3 = Kanji.create!(%{character: "三", grade: 1, stroke_count: 3, jlpt_level: 5})

      %{k1: k1, k2: k2, k3: k3}
    end

    test "fetches the correct kanji by offset, ordered by inserted_at", %{k1: k1, k2: k2, k3: k3} do
      {:ok, [fetched_k1]} = Kanji.by_offset(0)
      assert fetched_k1.id == k1.id
      assert fetched_k1.character == "一"

      {:ok, [fetched_k2]} = Kanji.by_offset(1)
      assert fetched_k2.id == k2.id
      assert fetched_k2.character == "二"

      {:ok, [fetched_k3]} = Kanji.by_offset(2)
      assert fetched_k3.id == k3.id
      assert fetched_k3.character == "三"
    end

    test "returns an empty list for an out-of-bounds offset", %{k1: _k1, k2: _k2, k3: _k3} do
      {:ok, result} = Kanji.by_offset(3)
      assert result == []

      {:ok, result_large_offset} = Kanji.by_offset(100)
      assert result_large_offset == []
    end

    test "returns only one record" do
      Kanji.create!(%{character: "四", grade: 1, stroke_count: 5, jlpt_level: 5})
      {:ok, result} = Kanji.by_offset(0)
      assert length(result) == 1
    end
  end
  
  describe ":count action (via count_all in code_interface)" do
    test "returns the total count of kanji" do
      # Ensure we start with a clean database
      {:ok, kanjis} = Ash.read(Kanji)
      if kanjis && length(kanjis) > 0 do
        Enum.each(kanjis, fn kanji ->
          Ash.destroy!(kanji)
        end)
      end
      
      initial_count = Kanji.count_all!()
      assert initial_count == 0

      Kanji.create!(%{character: "愛", grade: 4, stroke_count: 13, jlpt_level: 3})
      count_after_one = Kanji.count_all!()
      assert count_after_one == 1

      Kanji.create!(%{character: "犬", grade: 2, stroke_count: 4, jlpt_level: 4})
      count_after_two = Kanji.count_all!()
      assert count_after_two == 2
    end
  end
end
