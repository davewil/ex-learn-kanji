Code.compiler_options(ignore_module_conflict: true)

import Ecto.Query

# Get all duplicates
duplicates = KumaSanKanji.Repo.all(
  from k in "kanjis",
  group_by: k.character,
  having: count(k.id) > 1,
  select: %{
    character: k.character,
    count: count(k.id)
  }
)

if duplicates == [] do
  IO.puts("No duplicates found!")
else
  IO.puts("Found #{length(duplicates)} characters with duplicates:")
  for dup <- duplicates do
    IO.puts("#{dup.character}: #{dup.count} copies")
  end
end
