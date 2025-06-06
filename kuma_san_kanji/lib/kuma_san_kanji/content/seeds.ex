defmodule KumaSanKanji.Content.Seeds do
  @moduledoc """
  Seeds for the Content domain in Kuma-san Kanji.
  """

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
        description:
          "These form the foundation of the Japanese counting system and are among the first kanji taught.",
        # Warm red
        color_code: "oklch(0.7 0.15 45)",
        icon_name: "calculator",
        order_index: 1
      },
      %{
        name: "Nature",
        description: "Kanji related to natural world",
        color_code: "oklch(70% 0.2 150)",
        icon_name: "tree",
        order_index: 2,
        parent_id: nil
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
        description:
          "Kanji representing abstract ideas or those not fitting neatly into other categories.",
        # Muted purple
        color_code: "oklch(0.7 0.1 330)",
        icon_name: "puzzle-piece",
        order_index: 10
      }
    ]

    Enum.map(groups, fn group_attrs ->
      # Ensure parent_id is handled correctly if present, or defaults to nil
      # The create_thematic_group action should handle the parent_id attribute if it's defined on the resource
      # For now, we assume it's either part of group_attrs or handled by the action if missing.
      params =
        Map.take(group_attrs, [
          :name,
          :description,
          :color_code,
          :icon_name,
          :order_index,
          :parent_id
        ])

      {:ok, created} = Domain.create_thematic_group(params)
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

  defp map_kanji_to_content(thematic_groups_list, educational_contexts) do
    # Get all kanji
    # Assuming KumaSanKanji.Domain (or a specific Kanji domain) has a list_kanjis! function
    kanji_list =
      KumaSanKanji.Domain.list_kanjis!(load: [:meanings, :pronunciations, :example_sentences])

    # Convert thematic_groups list to a map for easier lookup by name
    thematic_groups_map =
      Enum.into(thematic_groups_list, %{}, fn group -> {group.name, group} end)

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
      # Simplified, assuming "Plants", "Earth", "Weather" are sub-categories or handled differently
      "木" => ["Nature"],
      "森" => ["Nature"],
      "林" => ["Nature"],
      "山" => ["Nature"],
      "川" => ["Nature"],
      "土" => ["Nature"],
      "空" => ["Nature"],
      "雨" => ["Nature"],
      # Also could be Time, but primary here as natural element
      "日" => ["Nature"],
      # Also could be Time
      "月" => ["Nature"],

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
      # Can also mean 'understand' or 'divide', context is key
      "分" => ["Time"]
    }

    # Create thematic group mappings and learning metadata
    Enum.each(kanji_list, fn kanji ->
      # Map to thematic groups
      group_names = Map.get(kanji_mapping, kanji.character, [])

      Enum.each(group_names, fn group_name ->
        # Use the map for lookup
        group = Map.get(thematic_groups_map, group_name)

        if group do
          {:ok, _} =
            Domain.create_kanji_thematic_group(%{
              kanji_id: kanji.id,
              thematic_group_id: group.id,
              # Default, can be adjusted
              relevance_score: 1.0,
              # Default, should be set based on actual order within group
              position: 0
            })
        else
          IO.puts(
            "Warning: Thematic group '#{group_name}' not found for kanji '#{kanji.character}'."
          )
        end
      end)

      # Create KanjiLearningMeta
      # Ensure kanji.grade is not nil before filtering
      if kanji.grade do
        contexts = Enum.filter(educational_contexts, &(&1.grade_level == kanji.grade))

        Enum.each(contexts, fn context ->
          params = %{
            kanji_id: kanji.id,
            educational_context_id: context.id,
            frequency_ranking: kanji.frequency
          }

          # Add notes only if jlpt is not nil
          params = if kanji.jlpt, do: Map.put(params, :notes, "JLPT N#{kanji.jlpt}"), else: params

          {:ok, _} = Domain.create_kanji_learning_meta(params)
        end)
      else
        IO.puts(
          "Warning: Kanji '#{kanji.character}' (ID: #{kanji.id}) has no grade level, skipping KanjiLearningMeta creation."
        )
      end
    end)
  end
end
