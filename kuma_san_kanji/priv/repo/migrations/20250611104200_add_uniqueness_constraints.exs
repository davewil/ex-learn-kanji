defmodule KumaSanKanji.Repo.Migrations.AddUniquenessConstraints do
  @moduledoc """
  Add unique constraints to prevent duplicate meanings, pronunciations, and example sentences.
  """

  use Ecto.Migration

  def up do
    # Add unique index for meanings - prevents duplicate meanings for the same kanji
    create unique_index(:kanji_meanings, [:kanji_id, :value, :language],
           name: "kanji_meanings_unique_per_kanji_index")

    # Add unique index for pronunciations - prevents duplicate pronunciations for the same kanji
    create unique_index(:kanji_pronunciations, [:kanji_id, :value, :type],
           name: "kanji_pronunciations_unique_per_kanji_index")

    # Add unique index for example sentences - prevents duplicate sentences for the same kanji
    create unique_index(:kanji_example_sentences, [:kanji_id, :japanese, :translation, :language],
           name: "kanji_example_sentences_unique_per_kanji_index")
  end

  def down do
    drop_if_exists unique_index(:kanji_meanings, [:kanji_id, :value, :language],
                   name: "kanji_meanings_unique_per_kanji_index")

    drop_if_exists unique_index(:kanji_pronunciations, [:kanji_id, :value, :type],
                   name: "kanji_pronunciations_unique_per_kanji_index")

    drop_if_exists unique_index(:kanji_example_sentences, [:kanji_id, :japanese, :translation, :language],
                   name: "kanji_example_sentences_unique_per_kanji_index")
  end
end
