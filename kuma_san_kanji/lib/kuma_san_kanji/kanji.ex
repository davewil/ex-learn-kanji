defmodule KumaSanKanji.Kanji do
  @moduledoc """
  The Kanji context for the application.
  
  This module provides the domain interface for kanji-related resources
  such as kanji, meanings, pronunciations, and example sentences.
  """
  use Ash.Domain

  resources do
    resource KumaSanKanji.Kanji.Kanji
    resource KumaSanKanji.Kanji.Meaning
    resource KumaSanKanji.Kanji.Pronunciation
    resource KumaSanKanji.Kanji.ExampleSentence
  end
end
