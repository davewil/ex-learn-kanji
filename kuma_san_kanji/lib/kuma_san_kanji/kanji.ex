defmodule KumaSanKanji.Kanji do
  @moduledoc """
  The Kanji context for the application.

  This module provides the domain interface for kanji-related resources
  such as kanji, meanings, pronunciations, and example sentences.
  """
  use Ash.Domain

  resources do
    resource KumaSanKanji.Kanji.Kanji do
      define :create, action: :create
      define :get_by_id, action: :get_by_id, args: [:id]
      define :by_offset, action: :by_offset, args: [:offset]
    end
    
    resource(KumaSanKanji.Kanji.Meaning)
    resource(KumaSanKanji.Kanji.Pronunciation)
    resource(KumaSanKanji.Kanji.ExampleSentence)
  end

  # Custom function to count all kanji
  def count_all! do
    KumaSanKanji.Kanji.Kanji
    |> Ash.read!(action: :count_all)
    |> length()
  end
end
