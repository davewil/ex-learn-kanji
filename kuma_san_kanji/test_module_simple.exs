# Simple test to verify Logic module is loaded
# This script just checks if the module can be accessed

IO.puts("🔍 Testing Logic module accessibility...")

try do
  # Check if module exists
  if Code.ensure_loaded?(KumaSanKanji.SRS.Logic) do
    IO.puts("✅ Logic module is loaded")

    # Check exported functions
    functions = KumaSanKanji.SRS.Logic.__info__(:functions)
    IO.puts("📋 Exported functions:")

    Enum.each(functions, fn {name, arity} ->
      IO.puts("  - #{name}/#{arity}")
    end)
  else
    IO.puts("❌ Logic module not loaded")
  end
rescue
  error ->
    IO.puts("❌ Error accessing Logic module:")
    IO.inspect(error)
end

IO.puts("🎯 Module test complete!")
