defmodule KumaSanKanji.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :kuma_san_kanji

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_app()

    # Start necessary applications for seeding
    start_seed_dependencies()

    IO.puts("Running database seeds...")
    # Call the seeding function from the Seeds module
    KumaSanKanji.Seeds.insert_initial_data()
    IO.puts("Database seeding completed")
  end

  def reset_and_seed do
    load_app()
    start_seed_dependencies()

    IO.puts("Starting database reset...")

    # Manually drop all tables to avoid migration rollback issues
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn repo ->
        # For SQLite, get all table names and drop them
        tables = repo.query!("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'", []).rows
        |> Enum.map(&List.first/1)
        |> Enum.reject(&(&1 == "schema_migrations"))

        Enum.each(tables, fn table ->
          repo.query!("DROP TABLE IF EXISTS #{table}", [])
          IO.puts("Dropped table: #{table}")
        end)

        # Also clean up the schema_migrations table
        repo.query!("DELETE FROM schema_migrations", [])
        IO.puts("Cleaned schema_migrations table")
      end)
    end

    IO.puts("Dropped all tables, running migrations...")

    # Run all migrations back up
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Migrations complete, seeding database...")

    # Seed the database
    KumaSanKanji.Seeds.insert_initial_data()

    IO.puts("Database reset and seeding completed!")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp start_seed_dependencies do
    # Start all required applications for Ash and telemetry
    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:ash)

    # Start the repository for database access
    for repo <- repos() do
      {:ok, _} = repo.start_link()
    end
  end
end
