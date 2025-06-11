defmodule KumaSanKanji.Kanji.PronunciationTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Kanji
  alias KumaSanKanji.Kanji.Pronunciation

  describe "Pronunciation resource actions" do
    setup do
      {:ok, kanji} = Kanji.create(%{character: "音", grade: 1, stroke_count: 9, jlpt_level: 4})
      %{kanji: kanji}
    end

    test "create action creates a pronunciation associated with a kanji", %{kanji: kanji} do
      params = %{
        type: "on",
        value: "オン",
        romaji: "on",
        kanji_id: kanji.id
      }

      {:ok, pronunciation} = Pronunciation.create(params)

      assert pronunciation.id
      assert pronunciation.type == "on"
      assert pronunciation.value == "オン"
      assert pronunciation.romaji == "on"
      assert pronunciation.kanji_id == kanji.id

      # Verify it can be read back via the relationship
      kanji_with_pronunciations = KumaSanKanji.Domain.get_kanji_by_id!(kanji.id, load: [:pronunciations])
      assert Enum.any?(kanji_with_pronunciations.pronunciations, &(&1.id == pronunciation.id))
    end

    test "create action requires a kanji_id" do
      params = %{type: "kun", value: "いぬ", romaji: "inu"}
      {:error, changeset} = Pronunciation.create(params)

      assert Enum.any?(changeset.errors, fn error ->
               match?(%Ash.Error.Changes.Required{field: :kanji_id}, error)
             end)
    end
  end
end
