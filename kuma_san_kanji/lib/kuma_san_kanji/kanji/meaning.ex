defmodule KumaSanKanji.Kanji.Meaning do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key(:id)
    attribute(:value, :string, allow_nil?: false)
    attribute(:language, :string, default: "en")
    attribute(:is_primary, :boolean, default: false)
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
      accept([:value, :language, :is_primary, :kanji_id])
    end

    read :by_kanji_and_value do
      argument :kanji_id, :uuid, allow_nil?: false
      argument :value, :string, allow_nil?: false
      argument :language, :string, default: "en"

      filter expr(kanji_id == ^arg(:kanji_id) and value == ^arg(:value) and 
        (language == ^arg(:language) or (is_nil(language) and ^arg(:language) == "en")))
    end
  end

  identities do
    identity :unique_meaning_per_kanji, [:kanji_id, :value, :language]
  end

  code_interface do
    define(:get, action: :read)
    define(:create, action: :create)
  end

  sqlite do
    table("kanji_meanings")
    repo(KumaSanKanji.Repo)
  end
end
