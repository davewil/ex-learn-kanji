defmodule KumaSanKanji.Content do
  @moduledoc """
  Content context for managing kanji thematic groups, educational context, and learning metadata.

  This module provides the high-level business interface for content-related operations,
  abstracting the underlying Ash resources and providing a clean API for the application.
  """

  alias KumaSanKanji.Content.Domain
  @doc """
  Gets thematic group information for a kanji character.
  """
  def get_thematic_group_for_kanji(kanji_id) do
    with {:ok, joins} <- Domain.get_kanji_group_joins(kanji_id),
         thematic_group_ids = Enum.map(joins, & &1.thematic_group_id),
         {:ok, groups} <- Domain.get_thematic_groups(filter: [id: [in: thematic_group_ids]]) do
      {:ok, groups, joins}
    else
      {:ok, []} -> {:ok, [], []}
      err -> err
    end
  end

  @doc """
  Gets educational context for a kanji based on its grade level.
  """
  def get_educational_context(grade) when is_integer(grade) do
    Domain.get_educational_context_by_grade(grade)
  end

  @doc """
  Gets usage examples for a kanji.
  """
  def get_usage_examples(kanji_id) do
    Domain.get_kanji_usage_examples(kanji_id)
  end

  @doc """
  Gets learning metadata for a kanji.
  """
  def get_learning_meta(kanji_id) do
    Domain.get_kanji_learning_meta(kanji_id)
  end
  @doc """
  Returns all thematic groups in order.
  """
  def get_all_thematic_groups do
    Domain.get_ordered_groups()
  end

  @doc """
  Returns all kanji in a specific thematic group, sorted by position.
  """
  def get_kanji_by_thematic_group(thematic_group_id) do
    with {:ok, joins} <- Domain.get_group_kanji_joins(thematic_group_id),
         kanji_ids = Enum.map(joins, & &1.kanji_id),
         {:ok, kanji} <- KumaSanKanji.Domain.read_kanji(
           filter: [id: [in: kanji_ids]],
           load: [:meanings, :pronunciations, :example_sentences]
         ) do

      sorted_kanji =
        Enum.sort_by(kanji, fn k ->
          position =
            Enum.find_value(joins, 0, fn j ->
              if j.kanji_id == k.id, do: j.position, else: nil
            end)
          {position, k.character}
        end)

      {:ok, sorted_kanji}
    end
  end
end
