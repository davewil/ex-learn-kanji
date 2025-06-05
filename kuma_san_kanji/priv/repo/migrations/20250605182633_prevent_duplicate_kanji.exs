defmodule KumaSanKanji.Repo.Migrations.PreventDuplicateKanji do
  @moduledoc """
  Adds a unique index on the character column of the kanjis table to prevent duplicates.
  """

  use Ecto.Migration

  def change do
    create unique_index(:kanjis, [:character], name: "kanjis_unique_character_index")
  end
end
