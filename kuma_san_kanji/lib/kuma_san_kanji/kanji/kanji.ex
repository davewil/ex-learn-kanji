defmodule KumaSanKanji.Kanji.Kanji do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  require Ash.Query

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

    has_many(:example_sentences, KumaSanKanji.Kanji.ExampleSentence,
      destination_attribute: :kanji_id
    )
  end

  actions do
    defaults([:read, :update, :destroy])

    # Simple read action to list all kanjis (for counting)
    read :count_all do
      # Will count results manually in domain
    end

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
        |> Ash.Query.filter(character: character)
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
        |> Ash.Query.filter(id: id)
        |> Ash.Query.load([:meanings, :pronunciations, :example_sentences])
        |> Ash.Query.limit(1)
      end)
    end

    # New action to get a Kanji by its order/offset
    read :by_offset do
      # Argument for the offset
      argument(:offset, :integer, allow_nil?: false)
      get? true

      prepare(fn query, _context ->
        # Get offset from query arguments
        offset = Ash.Query.get_argument(query, :offset)

        query
        |> Ash.Query.sort(:inserted_at)
        |> Ash.Query.offset(offset)
        |> Ash.Query.limit(1)
      end)
    end
  end

  sqlite do
    table("kanjis")
    repo(KumaSanKanji.Repo)
  end
end
