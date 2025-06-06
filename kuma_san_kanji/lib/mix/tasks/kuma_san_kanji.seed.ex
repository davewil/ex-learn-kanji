defmodule Mix.Tasks.KumaSanKanji.Seed do
  use Mix.Task

  @shortdoc "Seeds the database with initial kanji data"
  def run(_) do
    # Start the application
    Mix.Task.run("app.start")

    # Delete existing data
    IO.puts("Clearing existing data...")
    # This is a simplified approach; in a real app, you might want to be more careful
    {:ok, _} = Mix.Task.run("ash.reset", ["--domains", "KumaSanKanji.Domain", "--yes"])

    # Insert seed data
    IO.puts("Inserting seed data...")
    # Updated to call seed_all
    KumaSanKanji.Seeds.seed_all()

    # Verify the data was inserted
    # alias KumaSanKanji.Kanji.Kanji # Removed unused alias
    # Ensure Domain is aliased for the call below
    alias KumaSanKanji.Domain

    # Updated to use Domain.list_kanjis
    case Domain.list_kanjis() do
      {:ok, kanjis} ->
        IO.puts("Seed complete! Inserted #{length(kanjis)} kanji records.")

        if length(kanjis) > 0 do
          IO.puts("First few kanji:")

          kanjis
          |> Enum.take(3)
          |> Enum.each(fn kanji -> IO.puts("  - #{kanji.character}") end)
        end

      {:error, reason} ->
        IO.puts("Error verifying seed data: #{inspect(reason)}")
    end
  end
end
