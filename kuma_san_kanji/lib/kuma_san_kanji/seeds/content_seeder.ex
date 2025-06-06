defmodule KumaSanKanji.Seeds.ContentSeeder do
  @moduledoc """
  Seeds database with content-related data: thematic groups, educational context, etc.
  """

  alias KumaSanKanji.Content.Domain, as: ContentDomain
  alias KumaSanKanji.Domain, as: RootDomain
  alias KumaSanKanji.Kanji.Kanji

  @doc """
  Seeds all thematic groups from the Grade 1 kanji thematic groups guide.
  """
  def seed_thematic_groups do
    groups = [
      %{
        name: "Numbers",
        description: "These form the foundation of the Japanese counting system and are among the first kanji taught.",
        color_code: "oklch(0.7 0.15 45)", # Warm red
        icon_name: "calculator",
        order_index: 1
      },
      %{
        name: "Directions & Positions",
        description: "These spatial concepts are essential for basic navigation and describing locations.",
        color_code: "oklch(0.7 0.15 90)", # Yellow
        icon_name: "map-pin",
        order_index: 2
      },
      %{
        name: "Nature Elements",
        description: "These represent fundamental elements of the natural world that surround children in their daily lives.",
        color_code: "oklch(0.7 0.15 145)", # Green
        icon_name: "tree",
        order_index: 3
      },
      %{
        name: "People & Animals",
        description: "These characters represent basic social categories and common animals children encounter.",
        color_code: "oklch(0.7 0.15 200)", # Blue
        icon_name: "users",
        order_index: 4
      },
      %{
        name: "Body Parts",
        description: "Learning the kanji for body parts helps children describe themselves and basic health concepts.",
        color_code: "oklch(0.7 0.15 315)", # Pink
        icon_name: "heart",
        order_index: 5
      },
      %{
        name: "Actions & Concepts",
        description: "These represent basic actions and concepts that appear frequently in elementary texts.",
        color_code: "oklch(0.7 0.15 270)", # Purple
        icon_name: "play",
        order_index: 6
      },
      %{
        name: "Time",
        description: "These help children understand and express time concepts.",
        color_code: "oklch(0.7 0.15 170)", # Teal
        icon_name: "clock",
        order_index: 8
      }
    ]

    # Create thematic groups
    Enum.each(groups, fn group ->
      case ContentDomain.create_thematic_group(group) do
        {:ok, _created_group} ->
          IO.puts("Created thematic group: #{group.name}")
        {:error, error} ->
          IO.puts("Failed to create thematic group #{group.name}: #{inspect(error)}")
      end
    end)
  end

  @doc """
  Seeds the kanji thematic group associations.
  Maps kanji to their thematic group based on the Grade 1 guide.
  """
  def seed_kanji_thematic_groups do
    # Define the kanji-to-group mapping with subgroups where applicable
    mappings = [
      # Numbers (数字)
      %{group: "Numbers", kanji_chars: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "百", "千"]},
      # Directions & Positions (方向と位置)
      %{group: "Directions & Positions", kanji_chars: ["上", "下", "中", "左", "右"]},
      # Nature Elements (自然) with subgroups
      %{group: "Nature Elements", subgroup: "Basics", kanji_chars: ["水", "火", "木", "山", "川"]},
      %{group: "Nature Elements", subgroup: "Sky/Weather", kanji_chars: ["空", "雨", "天", "日", "月"]},
      %{group: "Nature Elements", subgroup: "Earth", kanji_chars: ["地", "石", "土"]},
      %{group: "Nature Elements", subgroup: "Plants", kanji_chars: ["花", "草", "竹", "林", "森", "田"]},
      # People & Animals (人と動物)
      %{group: "People & Animals", kanji_chars: ["人", "男", "女", "子", "犬", "虫"]},
      # Body Parts (体の部分)
      %{group: "Body Parts", kanji_chars: ["口", "目", "耳", "手", "足"]},
      # Actions & Concepts (動作と概念)
      %{group: "Actions & Concepts", kanji_chars: ["見", "立", "生", "休", "入", "出"]},
      # Colors (色)
      %{group: "Colors", kanji_chars: ["赤", "青", "白"]},
      # Time (時間)
      %{group: "Time", kanji_chars: ["年", "夕"]},
      # Places & Community (場所と社会)
      %{group: "Places & Community", kanji_chars: ["学", "校", "町", "村", "金"]},
      # Objects (物)
      %{group: "Objects", kanji_chars: ["車", "本", "玉", "貝", "円"]}
    ]
      # Process each group mapping
    # First handle mappings with subgroups
    mappings_with_subgroups = Enum.filter(mappings, &Map.has_key?(&1, :subgroup))
    results_with_subgroups = Enum.flat_map(mappings_with_subgroups, fn %{group: group_name, subgroup: subgroup, kanji_chars: kanji_chars} ->
      process_group_mapping(group_name, kanji_chars, subgroup)
    end)

    # Then handle mappings without subgroups
    mappings_without_subgroups = Enum.filter(mappings, &(!Map.has_key?(&1, :subgroup)))
    results_without_subgroups = Enum.flat_map(mappings_without_subgroups, fn %{group: group_name, kanji_chars: kanji_chars} ->
      process_group_mapping(group_name, kanji_chars, nil)
    end)

    # Combine results
    results_with_subgroups ++ results_without_subgroups
  end
    @doc """
  Seeds the educational context for all grade levels.
  """
  def seed_educational_contexts do
    contexts = [
      %{grade_level: 1, description: "First grade elementary school kanji (小学校一年生)"},
      %{grade_level: 2, description: "Second grade elementary school kanji (小学校二年生)"},
      %{grade_level: 3, description: "Third grade elementary school kanji (小学校三年生)"},
      %{grade_level: 4, description: "Fourth grade elementary school kanji (小学校四年生)"},
      %{grade_level: 5, description: "Fifth grade elementary school kanji (小学校五年生)"},
      %{grade_level: 6, description: "Sixth grade elementary school kanji (小学校六年生)"}
    ]

    Enum.each(contexts, fn context ->
      case ContentDomain.create_educational_context(context) do
        {:ok, _created_context} ->
          IO.puts("Created educational context for Grade #{context.grade_level}")
        {:error, error} ->
          IO.puts("Failed to create educational context for Grade #{context.grade_level}: #{inspect(error)}")
      end
    end)
  end
    @doc """
  Seeds usage examples for kanji.
  """
  def seed_kanji_usage_examples do
    usage_examples_data = [
      {"水", ["水曜日に友達と会います。", "彼は水泳が得意です。"]},
      {"木", ["木曜日に授業があります。", "公園に木々がたくさんあります。"]}
      # Add more as needed...
    ]

    Enum.each(usage_examples_data, fn {character, examples} ->
      with {:ok, [kanji]} <- RootDomain.read_kanji(Kanji, filter: [character: character]) do
        Enum.each(examples, fn example_text ->
          params = %{kanji_id: kanji.id, example: example_text, source: "Default Seed"}
          case ContentDomain.create_kanji_usage_example(params) do
            {:ok, _example} ->
              IO.puts("Created usage example for #{character}: #{example_text}")
            {:error, error} ->
              IO.puts("Failed to create usage example for #{character}: #{inspect(error)}")
          end
        end)
      else
        _ -> IO.puts("Kanji character '#{character}' not found when seeding usage examples.")
      end
    end)
  end
    @doc """
  Seeds learning metadata for kanji.
  """
  def seed_kanji_learning_meta do
    learning_meta_data = [
      {"水", [
        difficulty_score: 0.6,
        prerequisites: ["basic-strokes", "three-stroke-kanji"],
        learning_tips: """
        - Start with the left-most dot
        - The middle line extends slightly past the right vertical line
        - Practice the slight curve in the bottom "leg"
        """,
        common_mistakes: """
        - Forgetting to extend the middle line
        - Making the bottom strokes too straight
        - Wrong stroke order in the left side
        """,
        mnemonic_hints: "Imagine water flowing between two banks, with a dot of rain above"
      ]},
      {"木", [
        difficulty_score: 0.5,
        prerequisites: ["basic-strokes", "cross-stroke-kanji"],
        learning_tips: """
        - Think of drawing a stick figure of a tree
        - The horizontal stroke crosses through the vertical
        - Bottom strokes spread out like roots
        """,
        common_mistakes: """
        - Making the "branches" too long or short
        - Incorrect stroke order in the bottom "roots"
        - Misaligning the center cross
        """,
        mnemonic_hints: "Picture a tree with branches at the top, a trunk in the middle, and roots at the bottom"
      ]}
    ]

    # Get the JLPT N5 educational context for these basic kanji
    context_query = "SELECT id FROM educational_contexts WHERE name = 'JLPT N5 Level' LIMIT 1"
    {:ok, context_results} = Ecto.Adapters.SQL.query(KumaSanKanji.Repo, context_query, [])
    context_id = if length(context_results.rows) > 0, do: hd(hd(context_results.rows))

    Enum.each(learning_meta_data, fn {character, meta_items} ->
      with {:ok, [kanji]} <- RootDomain.read_kanji(KumaSanKanji.Kanji.Kanji, filter: [character: character]) do
        Enum.each(meta_items, fn meta_item ->
          # Remove character key and add kanji_id and educational_context_id
          params = meta_item
            |> Map.delete(:character)
            |> Map.put(:kanji_id, kanji.id)
            |> Map.put(:educational_context_id, context_id)

          case ContentDomain.create_kanji_learning_meta(params) do
            {:ok, _meta} ->
              IO.puts("Created learning meta for #{character} in context #{context_id}")
            {:error, error} ->
              IO.puts("Failed to create learning meta for #{character}: #{inspect(error)}")
          end
        end)
      else
        _ -> IO.puts("Kanji character '#{character}' not found when seeding learning meta.")
      end
    end)
  end

  # Private helper function to process each group mapping
  defp process_group_mapping(group_name, kanji_chars, subgroup) do
    # Find the thematic group
    with {:ok, [group]} <- ContentDomain.get_thematic_groups(filter: [name: group_name]) do # CHANGED
      # Find all the kanji
      kanji_chars_processed = Enum.map(kanji_chars, fn char ->
        case RootDomain.read_kanji(Kanji, filter: [character: char]) do # CHANGED
          {:ok, [kanji]} ->
            position = Enum.find_index(kanji_chars, &(&1 == char)) || 0

            params = %{
              kanji_id: kanji.id,
              thematic_group_id: group.id,
              position: position
            }

            # Add subgroup if present
            params = if subgroup, do: Map.put(params, :subgroup, subgroup), else: params

            case ContentDomain.create_kanji_thematic_group(params) do # CHANGED
              {:ok, created} -> {:ok, created}
              {:error, error} ->
                {:error, "Failed to create kanji thematic group for #{char}: #{inspect(error)}"}
            end

          _ -> {:error, "Kanji #{char} not found"}
        end
      end)
      |> Enum.reject(&is_nil/1) # Remove nils if kanji not found

      Enum.each(kanji_chars_processed, fn params ->
        if params do # Check if params is not nil
          case ContentDomain.create_kanji_thematic_group(params) do # CHANGED
            {:ok, _created} -> :ok
            {:error, error} -> IO.puts("Error creating kanji thematic group: #{inspect(error)}")
          end
        end
      end)
    else
      _ -> IO.puts("Thematic group '#{group_name}' not found during mapping.")
    end
  end

  @doc """
  Runs all content seeding operations.
  """
  def seed_all do
    IO.puts("Seeding thematic groups...")
    seed_thematic_groups()

    IO.puts("Seeding educational contexts...")
    seed_educational_contexts()

    IO.puts("Seeding kanji thematic group associations...")
    seed_kanji_thematic_groups()

    IO.puts("Seeding kanji usage examples...")
    seed_kanji_usage_examples()

    IO.puts("Seeding kanji learning metadata...")
    seed_kanji_learning_meta()

    IO.puts("Content seeding complete!")
  end
end
