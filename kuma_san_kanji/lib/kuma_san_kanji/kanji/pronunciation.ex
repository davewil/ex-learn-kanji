defmodule KumaSanKanji.Kanji.Pronunciation do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key(:id)
    attribute(:value, :string, allow_nil?: false)
    # "on" or "kun"
    attribute(:type, :string, allow_nil?: false)
    attribute(:romaji, :string, default: nil)
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
      accept([:value, :type, :romaji, :kanji_id])
    end

    read :by_kanji_and_value do
      argument :kanji_id, :uuid, allow_nil?: false
      argument :value, :string, allow_nil?: false
      argument :type, :string, allow_nil?: false

      filter expr(kanji_id == ^arg(:kanji_id) and value == ^arg(:value) and type == ^arg(:type))
    end
  end

  identities do
    identity :unique_pronunciation_per_kanji, [:kanji_id, :value, :type]
  end

  code_interface do
    define(:get, action: :read)
    define(:create, action: :create)
  end

  sqlite do
    table("kanji_pronunciations")
    repo(KumaSanKanji.Repo)
  end
end
