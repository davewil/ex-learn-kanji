defmodule KumaSanKanji.Content.KanjiLearningMeta do
  @moduledoc """
  Resource for kanji learning metadata.

  This includes learning tips, mnemonic hints, common mistakes, and prerequisites
  to help users learn and remember kanji effectively.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    # Changed from belongs_to
    attribute(:kanji_id, :uuid, allow_nil?: false)
    attribute(:difficulty_score, :float)
    attribute(:prerequisites, {:array, :string})
    attribute(:learning_tips, :string)
    attribute(:common_mistakes, :string)
    attribute(:mnemonic_hints, :string)
    timestamps()
  end

  relationships do
    # Removed belongs_to :kanji
    belongs_to :educational_context, KumaSanKanji.Content.EducationalContext do
      attribute_writable?(true)
      allow_nil?(true)
    end
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :by_kanji do
      argument(:kanji_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        kanji_id = Ash.Query.get_argument(query, :kanji_id)
        Ash.Query.filter(query, kanji_id == ^kanji_id)
      end)
    end

    read :by_educational_context do
      argument(:context_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        context_id = Ash.Query.get_argument(query, :context_id)
        query
        |> Ash.Query.filter(educational_context_id == ^context_id)
        |> Ash.Query.sort(difficulty_score: :asc)
      end)
    end
  end

  sqlite do
    table("kanji_learning_meta")
    repo(KumaSanKanji.Repo)
  end
end
