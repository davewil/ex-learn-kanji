defmodule KumaSanKanji.Scripts.CheckProgress do
  @moduledoc """
  Script to check user's kanji progress status.
  
  Run with:
  mix run check_progress.exs
  """
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.SRS.UserKanjiProgress
  require Ash.Query
    def run do    # Get test user
    {:ok, [user | _]} = User
      |> Ash.Query.filter(email == "test@example.com")
      |> Ash.read()
      
    IO.puts("=== Kanji Progress for #{user.email} ===")    # Check progress records
    import Ash.Query
    
    {:ok, progress_records} = UserKanjiProgress
      |> filter(user_id == ^user.id)  
      |> Ash.read()
    
    # Load the kanji relationship for each record
    progress_records = 
      case Ash.load(progress_records, :kanji) do
        {:ok, loaded} -> loaded
        {:error, _} -> progress_records # Fall back to original if loading fails
      end
      
    IO.puts("Total progress records: #{length(progress_records)}")
    
    now = DateTime.utc_now()
    
    # Count due items
    due_now = Enum.filter(progress_records, fn p -> 
      DateTime.compare(p.next_review_date, now) in [:lt, :eq]
    end)
    
    IO.puts("Items due for review: #{length(due_now)}")
    
    # Show some details about due items
    if length(due_now) > 0 do
      IO.puts("\nFirst 5 due kanji:")
      due_now
      |> Enum.take(5)
      |> Enum.each(fn p ->
        kanji_char = p.kanji.character
        due_time = p.next_review_date
        formatted_time = Calendar.strftime(due_time, "%Y-%m-%d %H:%M:%S")
        IO.puts("  #{kanji_char} - Due since: #{formatted_time}")
      end)
    end
  end
end

KumaSanKanji.Scripts.CheckProgress.run()
