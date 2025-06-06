defmodule KumaSanKanji.Content.EducationalContext do
  @moduledoc """
  Resource for educational context information for kanji.

  This includes grade levels, curriculum areas, and learning objectives
  for different groups of kanji.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false)
    attribute(:description, :string)
    attribute(:grade_level, :integer)
    attribute(:curriculum_area, :string)
    attribute(:learning_objectives, :string)
    timestamps()
  end

  relationships do
    has_many(:kanji_learning_meta, KumaSanKanji.Content.KanjiLearningMeta)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :by_grade_level do
      argument(:grade_level, :integer)

      prepare(fn query, _context ->
        grade_level = Ash.Query.get_argument(query, :grade_level)
        Ash.Query.filter(query, grade_level == ^grade_level)
      end)
    end
  end

  sqlite do
    table("educational_contexts")
    repo(KumaSanKanji.Repo)
  end
end
