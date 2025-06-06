defmodule KumaSanKanji.Content.KanjiLearningMeta do  @moduledoc """
  Resource for kanji learning metadata.
  
  This includes learning tips, mnemonic hints, common mistakes, and prerequisites
  to help users learn and remember kanji effectively.
  """
  
  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :difficulty_score, :float
    attribute :prerequisites, {:array, :string}
    attribute :learning_tips, :string
    attribute :common_mistakes, :string
    attribute :mnemonic_hints, :string
    timestamps()
  end

  relationships do
    belongs_to :kanji, KumaSanKanji.Kanji.Kanji do
      attribute_writable? true
      allow_nil? false
    end
    
    belongs_to :educational_context, KumaSanKanji.Content.EducationalContext do
      attribute_writable? true
      allow_nil? true
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_kanji do
      argument :kanji_id, :uuid, allow_nil?: false
      filter expr(kanji_id == arg(:kanji_id))
    end

    read :by_educational_context do
      argument :context_id, :uuid, allow_nil?: false
      filter expr(educational_context_id == arg(:context_id))

      prepare fn query, _context ->
        Ash.Query.sort(query, difficulty_score: :asc)
      end
    end
  end

  code_interface do
    define :get, action: :read
    define :create, action: :create
    define :by_kanji, args: [:kanji_id], action: :by_kanji
    define :by_educational_context, args: [:context_id], action: :by_educational_context
  end

  sqlite do
    table "kanji_learning_meta"
    repo KumaSanKanji.Repo
  end
end
