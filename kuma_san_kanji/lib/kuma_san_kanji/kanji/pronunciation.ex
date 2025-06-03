defmodule KumaSanKanji.Kanji.Pronunciation do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :value, :string, allow_nil?: false
    attribute :type, :string, allow_nil?: false # "on" or "kun"
    attribute :romaji, :string, default: nil
  end

  relationships do
    belongs_to :kanji, KumaSanKanji.Kanji.Kanji,
      allow_nil?: false,
      define_attribute?: true
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:value, :type, :romaji, :kanji_id]
    end
  end

  code_interface do
    define :get, action: :read
    define :create, action: :create
  end

  sqlite do
    table "kanji_pronunciations"
    repo KumaSanKanji.Repo
  end
end
