IO.puts("Running migrations...")
Ecto.Migrator.run(KumaSanKanji.Repo, Application.app_dir(:kuma_san_kanji, "priv/repo/migrations"), :up, all: true)
IO.puts("Migrations complete")
