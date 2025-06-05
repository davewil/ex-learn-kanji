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
