# Simple test to check function exports
IO.puts("🔍 Checking Logic module functions...")

# Check if the module exists
if Code.ensure_loaded?(KumaSanKanji.SRS.Logic) do
  IO.puts("✅ Logic module loaded")

  # Get function list
  functions = KumaSanKanji.SRS.Logic.__info__(:functions)
  IO.puts("📋 Functions found:")

  Enum.each(functions, fn {name, arity} ->
    IO.puts("  - #{name}/#{arity}")
  end)

  # Test specific functions
  target_functions = [
    {:get_due_kanji, 2},
    {:record_review, 3},
    {:initialize_progress, 2},
    {:get_user_stats, 1},
    {:bulk_initialize_progress, 2}
  ]

  IO.puts("🎯 Checking target functions:")

  Enum.each(target_functions, fn {name, arity} ->
    exported? = function_exported?(KumaSanKanji.SRS.Logic, name, arity)
    status = if exported?, do: "✅", else: "❌"
    IO.puts("  #{status} #{name}/#{arity}")
  end)
else
  IO.puts("❌ Logic module not loaded")
end
