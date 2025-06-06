Code.compiler_options(ignore_module_conflict: true)

defmodule KumaSanKanji.Repo.Migrations.AddContentDomainTables do
  @moduledoc """
  Adds tables for the Content domain including:
  - thematic_groups
  - kanji_thematic_groups (join table)
  - educational_contexts
  - kanji_usage_examples
  - kanji_learning_meta
  """

  use Ecto.Migration

  def change do
    # Create thematic groups table
    create table(:thematic_groups, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :description, :text
      add :color_code, :text
      add :icon_name, :text
      add :order_index, :integer
      add :parent_id, references(:thematic_groups, column: :id, type: :uuid)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:thematic_groups, [:parent_id])
    create unique_index(:thematic_groups, [:name, :parent_id], name: "thematic_groups_name_parent_index")

    # Create kanji thematic groups join table
    create table(:kanji_thematic_groups, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :kanji_id, references(:kanjis, column: :id, type: :uuid), null: false
      add :thematic_group_id, references(:thematic_groups, column: :id, type: :uuid), null: false
      add :relevance_score, :decimal
      add :notes, :text

      timestamps(type: :utc_datetime_usec)
    end

    create index(:kanji_thematic_groups, [:kanji_id])
    create index(:kanji_thematic_groups, [:thematic_group_id])
    create unique_index(:kanji_thematic_groups, [:kanji_id, :thematic_group_id],
      name: "kanji_thematic_groups_unique_index"
    )

    # Create educational contexts table
    create table(:educational_contexts, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :description, :text
      add :grade_level, :integer
      add :curriculum_area, :text
      add :learning_objectives, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:educational_contexts, [:name], name: "educational_contexts_name_index")

    # Create kanji usage examples table
    create table(:kanji_usage_examples, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :kanji_id, references(:kanjis, column: :id, type: :uuid), null: false
      add :context, :text, null: false
      add :romaji, :text
      add :translation, :text
      add :difficulty_level, :integer
      add :source, :text
      add :notes, :text

      timestamps(type: :utc_datetime_usec)
    end

    create index(:kanji_usage_examples, [:kanji_id])

    # Create kanji learning metadata table
    create table(:kanji_learning_meta, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :kanji_id, references(:kanjis, column: :id, type: :uuid), null: false
      add :educational_context_id, references(:educational_contexts, column: :id, type: :uuid)
      add :difficulty_score, :decimal
      add :prerequisites, {:array, :text}
      add :learning_tips, :text
      add :common_mistakes, :text
      add :mnemonic_hints, :text

      timestamps(type: :utc_datetime_usec)
    end

    create index(:kanji_learning_meta, [:kanji_id])
    create index(:kanji_learning_meta, [:educational_context_id])
    create unique_index(:kanji_learning_meta, [:kanji_id, :educational_context_id],
      name: "kanji_learning_meta_unique_index"
    )
  end
end
