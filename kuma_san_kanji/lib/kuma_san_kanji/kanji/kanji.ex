defmodule KumaSanKanji.Kanji.Kanji do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key(:id)
    attribute(:character, :string, allow_nil?: false)
    attribute(:grade, :integer, default: nil)
    attribute(:stroke_count, :integer, default: nil)
    attribute(:jlpt_level, :integer, default: nil)
    timestamps()
  end

  relationships do
    has_many(:meanings, KumaSanKanji.Kanji.Meaning, destination_attribute: :kanji_id)
    has_many(:pronunciations, KumaSanKanji.Kanji.Pronunciation, destination_attribute: :kanji_id)
    has_many(:example_sentences, KumaSanKanji.Kanji.ExampleSentence, destination_attribute: :kanji_id)
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:character, :grade, :stroke_count, :jlpt_level])
    end

    # List all kanji with relationships loaded
    read :list_all do
      prepare(fn query, _context ->
        query
        |> Ash.Query.load([:meanings, :pronunciations, :example_sentences])
        |> Ash.Query.sort(:inserted_at)
      end)
    end
    
    # Get kanji by character with relationships loaded
    read :get_by_character do
      argument(:character, :string, allow_nil?: false)

      prepare(fn query, _context ->
        character = Ash.Query.get_argument(query, :character)
        query
        |> Ash.Query.do_filter([character: character])
        |> Ash.Query.load([:meanings, :pronunciations, :example_sentences])
        |> Ash.Query.limit(1)
      end)
    end
    
    # Custom read action for getting by ID with relationships
    read :get_by_id do
      argument(:id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        id = Ash.Query.get_argument(query, :id)
        query
        |> Ash.Query.do_filter([id: id])
        |> Ash.Query.load([:meanings, :pronunciations, :example_sentences])
        |> Ash.Query.limit(1)
      end)
    end
      # New action to get a Kanji by its order/offset
    read :by_offset do
      # Argument for the offset
      argument(:offset, :integer, allow_nil?: false)

      prepare(fn query, context ->
        # Get offset from query.arguments
        offset = Map.get(query.arguments, :offset)

        query
        |> Ash.Query.sort(:inserted_at)
        |> Ash.Query.offset(offset)
        |> Ash.Query.select([:id, :character, :grade, :stroke_count, :jlpt_level])
        |> Ash.Query.limit(1)
      end)
    end
  end

  # Calculate count using read action and length
  def count_all do
    case Ash.read(__MODULE__) do
      {:ok, kanjis} -> length(kanjis)
      _ -> 0
    end
  end

  def count_all! do
    {:ok, kanjis} = Ash.read(__MODULE__)
    length(kanjis)
  end

  code_interface do
    define(:get, action: :read)
    define(:get_by_id, args: [:id], action: :get_by_id)
    define(:create, action: :create)
    define(:by_offset, args: [:offset], action: :by_offset)
    define(:list_all, action: :list_all)
    define(:get_by_character, args: [:character], action: :get_by_character)
  end

  sqlite do
    table("kanjis")
    repo(KumaSanKanji.Repo)
  end
end