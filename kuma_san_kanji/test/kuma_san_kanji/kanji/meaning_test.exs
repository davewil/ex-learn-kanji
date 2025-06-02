defmodule KumaSanKanji.Kanji.MeaningTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Kanji.Kanji
  alias KumaSanKanji.Kanji.Meaning

  describe "Meaning resource actions" do
    setup do
      {:ok, kanji} = Kanji.create(%{character: "試", grade: 1, stroke_count: 8, jlpt_level: 3})
      %{kanji: kanji}
    end

    test "create action creates a meaning associated with a kanji", %{kanji: kanji} do
      params = %{
        value: "test, trial, experiment",
        language: "en",
        is_primary: true,
        kanji_id: kanji.id
      }

      {:ok, meaning} = Meaning.create(params)

      assert meaning.id
      assert meaning.value == "test, trial, experiment"
      assert meaning.language == "en"
      assert meaning.is_primary == true
      assert meaning.kanji_id == kanji.id
      
      # Verify it can be read back via the relationship
      {:ok, [kanji_with_meanings]} = Kanji.get_by_id(kanji.id, load: [:meanings])
      assert Enum.any?(kanji_with_meanings.meanings, &(&1.id == meaning.id))
    end

    test "create action requires a kanji_id" do
      params = %{value: "tree, wood", language: "en", is_primary: true}
      {:error, changeset} = Meaning.create(params)

      assert Enum.any?(changeset.errors, fn error ->
        match?(%Ash.Error.Changes.Required{field: :kanji_id}, error)
      end)
    end
  end
end
