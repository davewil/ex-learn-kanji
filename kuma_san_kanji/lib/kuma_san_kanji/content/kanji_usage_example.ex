defmodule KumaSanKanji.Content.KanjiUsageExample do  @moduledoc """
  Resource for kanji usage examples.
  
  This includes example sentences, translations, and difficulty levels
  to help users understand how kanji are used in context.
  """
  
  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :context, :string, allow_nil?: false
    attribute :romaji, :string
    attribute :translation, :string
    attribute :difficulty_level, :integer
    attribute :source, :string
    attribute :notes, :string
    timestamps()
  end

  relationships do
    belongs_to :kanji, KumaSanKanji.Kanji.Kanji do
      attribute_writable? true
      allow_nil? false
    end
  end
  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_kanji do
      argument :kanji_id, :uuid, allow_nil?: false
      filter expr(kanji_id == arg(:kanji_id))

      prepare fn query, _context ->
        Ash.Query.sort(query, difficulty_level: :asc)
      end
    end
  end

  sqlite do
    table "kanji_usage_examples"
    repo KumaSanKanji.Repo
  end
end
