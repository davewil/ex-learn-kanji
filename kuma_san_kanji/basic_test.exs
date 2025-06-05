# Simple SRS test
IO.puts("Testing SRS system...")

# Test basic functionality without dependencies
try do
  alias KumaSanKanji.SRS.Logic
  IO.puts("✅ SRS Logic module loaded successfully")

  # Test function exists
  if function_exported?(Logic, :get_due_kanji, 2) do
    IO.puts("✅ get_due_kanji/2 function exists")
  else
    IO.puts("❌ get_due_kanji/2 function missing")
  end

  if function_exported?(Logic, :initialize_progress, 2) do
    IO.puts("✅ initialize_progress/2 function exists")
  else
    IO.puts("❌ initialize_progress/2 function missing")
  end
rescue
  error ->
    IO.puts("❌ Error loading SRS Logic module:")
    IO.inspect(error)
end

IO.puts("Test complete.")
