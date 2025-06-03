defmodule KumaSanKanji.Kanji.ExampleSentenceTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Kanji.Kanji
  alias KumaSanKanji.Kanji.ExampleSentence

  describe "ExampleSentence resource actions" do
    setup do
      # Create a fresh kanji for testing
      {:ok, kanji} = Kanji.create(%{character: "文", grade: 1, stroke_count: 4, jlpt_level: 5})
      %{kanji: kanji}
    end

    test "create action creates an example sentence associated with a kanji", %{kanji: kanji} do
      params = %{
        japanese: "これは例文です。",
        language: "en",
        translation: "This is an example sentence.",
        kanji_id: kanji.id
      }

      {:ok, example_sentence} = ExampleSentence.create(params)

      assert example_sentence.id
      assert example_sentence.japanese == "これは例文です。"
      assert example_sentence.language == "en"
      assert example_sentence.translation == "This is an example sentence."
      assert example_sentence.kanji_id == kanji.id
      # Verify it can be read back via the relationship
      {:ok, [kanji_with_examples]} = Kanji.get_by_id(kanji.id, load: [:example_sentences])
      assert Enum.any?(kanji_with_examples.example_sentences, fn es -> es.id == example_sentence.id end)
    end

    test "create action requires a kanji_id" do
      params = %{japanese: "猫が窓から頭を出した。", translation: "The cat stuck its head out the window.", language: "en"}
      {:error, changeset} = ExampleSentence.create(params)

      assert Enum.any?(changeset.errors, fn error ->
        match?(%Ash.Error.Changes.Required{field: :kanji_id}, error)
      end)
    end
  end
end
