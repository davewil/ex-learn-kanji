defmodule KumaSanKanji.Seeds.ContentSeeds do
  @moduledoc """
  Seeds for the Content domain in Kuma-san Kanji.
  """

  alias KumaSanKanji.Content.ThematicGroup
  alias KumaSanKanji.Content.KanjiThematicGroup
  alias KumaSanKanji.Content.EducationalContext 
  alias KumaSanKanji.Content.KanjiLearningMeta
  alias KumaSanKanji.Content.KanjiUsageExample

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
      # Grade 1 Categories
      %{
        name: "Numbers",
        description: "These form the foundation of the Japanese counting system and are among the first kanji taught.",
        color_code: "oklch(0.7 0.15 45)",
        icon_name: "calculator",
        order_index: 1,
        parent_id: nil
      },
      %{
        name: "Directions & Positions",
        description: "These spatial concepts are essential for basic navigation and describing locations.",
        color_code: "oklch(0.7 0.15 90)",
        icon_name: "map-pin",
        order_index: 2,
        parent_id: nil
      },
      %{
        name: "Nature",
        description: "These represent fundamental elements of the natural world that surround children in their daily lives.",
        color_code: "oklch(0.7 0.15 145)",
        icon_name: "tree",
        order_index: 3,
        parent_id: nil
      },
      %{
        name: "People & Animals",
        description: "These characters represent basic social categories and common animals children encounter.",
        color_code: "oklch(0.7 0.15 200)",
        icon_name: "users",
        order_index: 4,
        parent_id: nil
      },
      %{
        name: "Body Parts",
        description: "Learning the kanji for body parts helps children describe themselves and basic health concepts.",
        color_code: "oklch(0.7 0.15 315)",
        icon_name: "heart",
        order_index: 5,
        parent_id: nil
      },
      %{
        name: "Actions & Concepts",
        description: "These represent basic actions and concepts that appear frequently in elementary texts.",
        color_code: "oklch(0.7 0.15 270)",
        icon_name: "play",
        order_index: 6,
        parent_id: nil
      },
      %{
        name: "Time",
        description: "These help children understand and express time concepts.",
        color_code: "oklch(0.7 0.15 170)",
        icon_name: "clock",
        order_index: 7,
        parent_id: nil
      },
      %{
        name: "Places & Community",
        description: "These relate to the child's immediate community and social environment.",
        color_code: "oklch(0.7 0.15 120)",
        icon_name: "building",
        order_index: 8,
        parent_id: nil
      },
      %{
        name: "Objects",
        description: "Common objects children interact with or see regularly.",
        color_code: "oklch(0.7 0.15 60)", 
        icon_name: "box",
        order_index: 9,
        parent_id: nil
      },
      
      # Nature Subcategories
      %{
        name: "Weather",
        description: "Weather-related kanji",
        color_code: "oklch(0.7 0.15 150)",
        icon_name: "cloud",
        order_index: 1,
        parent_name: "Nature"
      },
      %{
        name: "Plants",
        description: "Plant and vegetation kanji",
        color_code: "oklch(0.7 0.15 160)",
        icon_name: "leaf",
        order_index: 2,
        parent_name: "Nature"
      },
      %{
        name: "Earth",
        description: "Kanji for land, ground, and geographical features",
        color_code: "oklch(0.7 0.15 170)",
        icon_name: "mountain",
        order_index: 3,
        parent_name: "Nature"
      },
      %{
        name: "Colors",
        description: "Basic color kanji that children learn first",
        color_code: "oklch(0.7 0.15 280)",
        icon_name: "palette",
        order_index: 4,
        parent_name: "Nature"
      }
    ]

    # First pass - create all root groups
    root_groups = groups
    |> Enum.filter(fn g -> is_nil(g.parent_id) end)
    |> Enum.map(fn group ->      {:ok, created} = ThematicGroup
        |> Ash.Changeset.for_create(:create, group)
        |> Ash.create!()
      {group.name, created}
    end)
    |> Map.new()

    # Second pass - create child groups with parent IDs
    child_groups = groups
    |> Enum.filter(fn g -> not is_nil(g[:parent_name]) end)
    |> Enum.map(fn group ->
      parent = root_groups[group.parent_name]
      attrs = group
      |> Map.take([:name, :description, :color_code, :icon_name, :order_index])
      |> Map.put(:parent_id, parent.id)
        {:ok, created} = ThematicGroup
        |> Ash.Changeset.for_create(:create, attrs)
        |> Ash.create!()
      {group.name, created}
    end)
    |> Map.new()

    Map.merge(root_groups, child_groups)
  end

  defp insert_educational_contexts do
    contexts = [
      %{
        name: "Japanese Elementary School Grade 1",
        description: "First grade elementary school kanji in Japanese education system",
        grade_level: 1,
        curriculum_area: "Japanese Elementary Education",
        learning_objectives: """
        - Master basic kanji with simple stroke counts
        - Learn kanji used in daily life situations
        - Understand basic radicals and components
        - Write kanji with correct stroke order
        """
      },
      %{
        name: "JLPT N5 Level",
        description: "Basic level Japanese Language Proficiency Test kanji",
        grade_level: 1,
        curriculum_area: "JLPT Certification",
        learning_objectives: """
        - Recognize and read basic kanji
        - Write simple kanji used in everyday situations
        - Understand basic compound words
        - Master basic radicals
        """
      },
      %{
        name: "Japanese Elementary School Grade 2",
        description: "Second grade elementary school kanji in Japanese education system",
        grade_level: 2,
        curriculum_area: "Japanese Elementary Education",
        learning_objectives: """
        - Build on Grade 1 kanji knowledge
        - Learn more complex compounds
        - Master intermediate stroke orders
        - Understand meaning relationships
        """
      }
    ]

    contexts
    |> Enum.map(fn context ->      {:ok, created} = EducationalContext
        |> Ash.Changeset.for_create(:create, context)
        |> Ash.create!()
      {context.name, created}
    end)
    |> Map.new()
  end

  defp map_kanji_to_content(groups, contexts) do    # Get all kanji
    {:ok, _kanji_list} = KumaSanKanji.Kanji.Kanji.list_all()

    # Create thematic group mappings
    kanji_mappings = [
      # Numbers (数字)
      %{group: "Numbers", kanji_chars: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千"]},
      # Directions & Positions (方向と位置)
      %{group: "Directions & Positions", kanji_chars: ["上", "下", "中", "左", "右"]},
      # Nature Elements (自然) with subgroups
      %{group: "Nature", subgroup: "Basics", kanji_chars: ["水", "火", "木", "山", "川"]},
      %{group: "Nature", subgroup: "Sky/Weather", kanji_chars: ["空", "雨", "天", "日", "月"]},
      %{group: "Nature", subgroup: "Earth", kanji_chars: ["地", "石", "土"]},
      %{group: "Nature", subgroup: "Plants", kanji_chars: ["花", "草", "竹", "林", "森", "田"]},
      # People & Animals (人と動物)
      %{group: "People & Animals", kanji_chars: ["人", "男", "女", "子", "犬", "虫"]},
      # Body Parts (体の部分)  
      %{group: "Body Parts", kanji_chars: ["口", "目", "耳", "手", "足"]},
      # Actions & Concepts (動作と概念)
      %{group: "Actions & Concepts", kanji_chars: ["見", "立", "生", "休", "入", "出"]},
      # Colors (色)
      %{group: "Nature", subgroup: "Colors", kanji_chars: ["赤", "青", "白"]},
      # Time (時間)
      %{group: "Time", kanji_chars: ["年", "夕"]},
      # Places & Community (場所と社会)
      %{group: "Places & Community", kanji_chars: ["学", "校", "町", "村", "金"]},
      # Objects (物)
      %{group: "Objects", kanji_chars: ["車", "本", "玉", "貝", "円"]}
    ]

    # Process each group mapping
    Enum.each(kanji_mappings, fn mapping ->
      group_name = mapping.group
      subgroup = Map.get(mapping, :subgroup)
      kanji_chars = mapping.kanji_chars

      if group = groups[group_name] do
        Enum.each(Enum.with_index(kanji_chars), fn {char, idx} ->
          with {:ok, kanji} <- KumaSanKanji.Kanji.Kanji.get_by_character(char) do
            # Create kanji-thematic group association
            attrs = %{
              kanji_id: kanji.id,
              thematic_group_id: group.id,
              position: idx,
              relevance_score: if(subgroup, do: 1.0, else: 0.5),
              notes: if(subgroup, do: subgroup, else: nil)
            }
              {:ok, _} = KanjiThematicGroup
              |> Ash.Changeset.for_create(:create, attrs)
              |> Ash.create!()

            # Create learning metadata for each kanji
            difficulty_score = calculate_difficulty_score(kanji)
            prerequisites = determine_prerequisites(kanji)
            learning_tips = generate_learning_tips(kanji)
            common_mistakes = identify_common_mistakes(kanji)
            mnemonic_hints = create_mnemonic_hints(kanji)

            # Add metadata to each educational context
            Enum.each(contexts, fn {_, context} ->
              metadata_attrs = %{
                kanji_id: kanji.id,
                educational_context_id: context.id,
                difficulty_score: difficulty_score,                prerequisites: prerequisites,
                learning_tips: learning_tips,
                common_mistakes: common_mistakes,
                mnemonic_hints: mnemonic_hints
              }
              
              {:ok, _} = KanjiLearningMeta
                |> Ash.Changeset.for_create(:create, metadata_attrs)
                |> Ash.create!()
            end)

            # Create usage examples for basic kanji
            if kanji.grade == 1 do
              create_usage_examples(kanji)
            end
          end
        end)
      end
    end)
  end

  defp create_usage_examples(kanji) do
    examples = case kanji.character do
      "水" -> [
        %{
          context: "水曜日に友達と会います。",
          romaji: "suiyōbi ni tomodachi to aimasu",
          translation: "I will meet my friend on Wednesday",
          difficulty_level: 1,
          source: "Basic conversation",
          notes: "Common usage in calendar context"
        },
        %{
          context: "彼は水泳が得意です。",
          romaji: "kare wa suiei ga tokui desu",
          translation: "He is good at swimming",
          difficulty_level: 2,
          source: "Basic conversation", 
          notes: "Sports context usage"
        }
      ]
      "木" -> [
        %{
          context: "木曜日に授業があります。",
          romaji: "mokuyōbi ni jugyō ga arimasu",
          translation: "There is a class on Thursday",
          difficulty_level: 1,
          source: "Basic conversation",
          notes: "Calendar context usage"
        },
        %{
          context: "公園に木々がたくさんあります。",
          romaji: "kōen ni kigi ga takusan arimasu",
          translation: "There are many trees in the park",
          difficulty_level: 2,
          source: "Basic description",
          notes: "Natural plural usage with 々"
        }
      ]
      _ -> []
    end

    Enum.each(examples, fn example ->      {:ok, _} = KanjiUsageExample
        |> Ash.Changeset.for_create(:create, Map.put(example, :kanji_id, kanji.id))
        |> Ash.create!()
    end)
  end

  # Helper functions for generating kanji metadata
  defp calculate_difficulty_score(kanji) do
    # Base difficulty from stroke count (normalized to 0-1 range, most complex kanji has ~30 strokes)
    stroke_factor = kanji.stroke_count / 30.0
    
    # Grade level factor (earlier grade = easier)
    grade_factor = if kanji.grade, do: (7 - kanji.grade) / 6.0, else: 0.5
    
    # JLPT level factor (N5 easiest, N1 hardest)
    jlpt_factor = if kanji.jlpt_level, do: (6 - kanji.jlpt_level) / 5.0, else: 0.5

    # Combine factors (weighted average)
    difficulty = (0.4 * stroke_factor + 0.3 * grade_factor + 0.3 * jlpt_factor)
    |> max(0.1) 
    |> min(1.0)
    
    # Scale to 1-5 range
    1.0 + (difficulty * 4.0)
  end
  defp determine_prerequisites(_kanji), do: ["basic-strokes"]  # Simplified for now
  defp generate_learning_tips(_kanji), do: "Practice basic strokes and proper stroke order."  # Simplified for now
  defp identify_common_mistakes(_kanji), do: "Watch for proper stroke order and proportions."  # Simplified for now
  defp create_mnemonic_hints(_kanji), do: "Look for visual elements that relate to the kanji's meaning."  # Simplified for now
end
