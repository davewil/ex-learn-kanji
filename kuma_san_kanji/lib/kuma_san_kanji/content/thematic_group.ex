defmodule KumaSanKanji.Content.ThematicGroup do
  @moduledoc """
  Resource for thematic groups.

  Thematic groups organize kanji into meaningful categories like "Numbers",
  "Nature", "People", etc. with support for hierarchical grouping and
  visual customization through colors and icons.
  """
  use Ash.Resource,
    domain: KumaSanKanji.Content.Domain,
    data_layer: AshSqlite.DataLayer

  # Ensure Ash.Query is required
  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false)
    attribute(:description, :string)
    attribute(:color_code, :string)
    attribute(:icon_name, :string)
    attribute(:order_index, :integer)
    timestamps()
  end

  relationships do
    belongs_to :parent, __MODULE__ do
      attribute_writable?(true)
      allow_nil?(true)
    end

    has_many(:children, __MODULE__, destination_attribute: :parent_id)
    has_many(:kanji_associations, KumaSanKanji.Content.KanjiThematicGroup)
  end

  actions do
    defaults([:create, :read, :update, :destroy])

    read :by_name do
      argument(:name, :string, allow_nil?: false)

      prepare(fn query, _context ->
        name_val = Ash.Query.get_argument(query, :name)
        Ash.Query.filter(query, name == ^name_val)
      end)
    end

    read :ordered do
      prepare(fn query, _context ->
        Ash.Query.sort(query, order_index: :asc)
      end)
    end

    read :root_groups do
      filter(expr(is_nil(parent_id)))

      prepare(fn query, _context ->
        Ash.Query.sort(query, order_index: :asc)
      end)
    end
  end

  sqlite do
    table("thematic_groups")
    repo(KumaSanKanji.Repo)
  end
end
