defmodule KumaSanKanji.Kanji.ExampleSentence do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key(:id)
    attribute(:japanese, :string, allow_nil?: false)
    attribute(:translation, :string, allow_nil?: false)
    attribute(:language, :string, default: "en")
  end

  relationships do
    belongs_to(:kanji, KumaSanKanji.Kanji.Kanji,
      allow_nil?: false,
      define_attribute?: true
    )
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:japanese, :translation, :language, :kanji_id])
    end

    read :by_kanji_and_text do
      argument :kanji_id, :uuid, allow_nil?: false
      argument :japanese, :string, allow_nil?: false
      argument :translation, :string, allow_nil?: false
      argument :language, :string, default: "en"

      filter expr(kanji_id == ^arg(:kanji_id) and japanese == ^arg(:japanese) and 
        translation == ^arg(:translation) and 
        (language == ^arg(:language) or (is_nil(language) and ^arg(:language) == "en")))
    end
  end

  identities do
    identity :unique_sentence_per_kanji, [:kanji_id, :japanese, :translation, :language]
  end

  code_interface do
    define(:get, action: :read)
    define(:create, action: :create)
  end

  sqlite do
    table("kanji_example_sentences")
    repo(KumaSanKanji.Repo)
  end
end
