defmodule KumaSanKanji.Content.KanjiThematicGroup do
  @moduledoc """
  Join table resource between Kanji and ThematicGroup resources.

  This allows many-to-many relationships between kanji and thematic groups,
  with additional metadata like relevance scores and notes.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer
  attributes do
    uuid_primary_key :id
    attribute :kanji_id, :uuid, allow_nil?: false
    attribute :relevance_score, :float, default: 1.0
    attribute :notes, :string
    timestamps()
  end

  relationships do
    belongs_to :thematic_group, KumaSanKanji.Content.ThematicGroup do
      attribute_writable? true
      allow_nil? false    end
  end
  actions do
    defaults [:create, :read, :update, :destroy]

    read :by_kanji do
      argument :kanji_id, :uuid, allow_nil?: false
      filter expr(kanji_id == arg(:kanji_id))
    end

    read :by_group do
      argument :thematic_group_id, :uuid, allow_nil?: false
      filter expr(thematic_group_id == arg(:thematic_group_id))

      prepare fn query, _context ->
        Ash.Query.sort(query, relevance_score: :desc)
      end
    end
  end

  sqlite do
    table "kanji_thematic_groups"
    repo KumaSanKanji.Repo
  end
end
