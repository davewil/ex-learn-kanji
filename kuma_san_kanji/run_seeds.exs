defmodule Seeder do
  def run do
    IO.puts("Running seeds...")
    KumaSanKanji.Seeds.insert_initial_data()
    IO.puts("Seeds completed.")
  end
end

Seeder.run()
