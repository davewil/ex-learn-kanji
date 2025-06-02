defmodule KumaSanKanji.Repo do
  use AshSqlite.Repo, otp_app: :kuma_san_kanji

  # This repo will be used by resources with AshSqlite.DataLayer
end
