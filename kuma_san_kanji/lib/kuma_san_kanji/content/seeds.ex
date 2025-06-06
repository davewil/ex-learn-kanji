defmodule KumaSanKanji.Content.Seeds do
  @moduledoc """
  Seeds for the Content domain in Kuma-san Kanji.
  """

  alias KumaSanKanji.Kanji
  alias KumaSanKanji.Content.Domain

  def insert_initial_data do
    # Create initial thematic groups
    thematic_groups = insert_thematic_groups()

    # Create educational contexts
    educational_contexts = insert_educational_contexts()

    # Map kanji to groups and create learning metadata
    map_kanji_to_content(thematic_groups, educational_contexts)
  end

  defp insert_thematic_groups do
    groups = [
      # Basic Categories
      %{
        name: "Numbers",
        description: "These form the foundation of the Japanese counting system and are among the first kanji taught.",
        color_code: "oklch(0.7 0.15 45)", # Warm red
        icon_name: "calculator",
        order_index: 1
      },
      %{
        name: "Nature",
        description: "Kanji related to natural world",
        color_code: "oklch(70% 0.2 150)",
        icon_name: "tree",
        order_index: 2,
        parent_id: nil,
      },
      %{
        name: "People",
        description: "Kanji related to humans and body",
        color_code: "oklch(70% 0.2 60)",
        icon_name: "person",
        order_index: 3,
        parent_id: nil
      },
      %{
        name: "Actions",
        description: "Kanji representing verbs and activities",
        color_code: "oklch(70% 0.2 200)",
        icon_name: "play",
        order_index: 4,
        parent_id: nil
      },
      %{
        name: "Time",
        description: "Kanji related to time concepts",
        color_code: "oklch(70% 0.2 90)",
        icon_name: "clock",
        order_index: 5,
        parent_id: nil
      },
      %{
        name: "Abstract Concepts & Others",
        description: "Kanji representing abstract ideas or those not fitting neatly into other categories.",
        color_code: "oklch(0.7 0.1 330)", # Muted purple
        icon_name: "puzzle-piece",
        order_index: 10
      }
    ]

    Enum.map(groups, fn group ->
      {:ok, created} = Domain.create_thematic_group(Map.take(group, [:name, :description, :color_code, :icon_name, :order_index]))
      created
    end)
  end

  defp insert_educational_contexts do
    contexts = [
      %{grade_level: 1, description: "First grade elementary school kanji (小学校一年生)"},
      %{grade_level: 2, description: "Second grade elementary school kanji (小学校二年生)"},
      %{grade_level: 3, description: "Third grade elementary school kanji (小学校三年生)"},
      %{grade_level: 4, description: "Fourth grade elementary school kanji (小学校四年生)"},
      %{grade_level: 5, description: "Fifth grade elementary school kanji (小学校五年生)"},
      %{grade_level: 6, description: "Sixth grade elementary school kanji (小学校六年生)"}
      # Add more contexts as needed for secondary school, JLPT levels, etc.
    ]

    Enum.map(contexts, fn context ->
      {:ok, created} = Domain.create_educational_context(context)
      created
    end)
  end

  defp map_kanji_to_content(thematic_groups, educational_contexts) do
    # Get all kanji
    {:ok, kanji_list} = Kanji.Kanji.get()

    kanji_mapping = %{
      # Numbers group
      "一" => ["Numbers"],
      "七" => ["Numbers"],
      "三" => ["Numbers"],
      "九" => ["Numbers"],
      "二" => ["Numbers"],
      "五" => ["Numbers"],
      "八" => ["Numbers"],
      "六" => ["Numbers"],
      "四" => ["Numbers"],
      "十" => ["Numbers"],

      # Nature groups
      "木" => ["Nature", "Plants"],
      "森" => ["Nature", "Plants"],
      "林" => ["Nature", "Plants"],
      "山" => ["Nature", "Earth"],
      "川" => ["Nature", "Earth"],
      "土" => ["Nature", "Earth"],
      "空" => ["Nature", "Weather"],
      "雨" => ["Nature", "Weather"],
      "日" => ["Nature", "Weather"],
      "月" => ["Nature", "Weather"],

      # People group
      "人" => ["People"],
      "子" => ["People"],
      "女" => ["People"],
      "男" => ["People"],

      # Actions group
      "見" => ["Actions"],
      "聞" => ["Actions"],
      "行" => ["Actions"],
      "来" => ["Actions"],

      # Time group
      "年" => ["Time"],
      "時" => ["Time"],
      "分" => ["Time"]
    }

    # Create thematic group mappings and learning metadata
    Enum.each(kanji_list, fn kanji ->
      # Map to thematic groups
      group_names = Map.get(kanji_mapping, kanji.character, [])

      Enum.each(group_names, fn group_name ->
        group = thematic_groups[group_name]
        if group do
          {:ok, _} = Domain.create_kanji_thematic_group(%{
            kanji_id: kanji.id,
            thematic_group_id: group.id,
            relevance_score: 1.0 # Default, can be adjusted
          })
        end
      end)

      # Create KanjiLearningMeta
      contexts = Enum.filter(educational_contexts, &(&1.grade_level == kanji.grade))
      Enum.each(contexts, fn context ->
        {:ok, _} = Domain.create_kanji_learning_meta(%{
          kanji_id: kanji.id,
          educational_context_id: context.id,
          frequency_ranking: kanji.frequency,
          notes: "JLPT N#{kanji.jlpt}" # Example note
        })
      end)
    end)
  end
end
