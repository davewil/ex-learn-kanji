defmodule KumaSanKanji.Domain do
  @moduledoc """
  The boundary to the KumaSanKanji system.
  """
  use Ash.Domain, otp_app: :kuma_san_kanji
  require Ash.Query

  resources do
    resource(KumaSanKanji.Accounts.User)

    resource(KumaSanKanji.Kanji.Kanji) do
      define(:read_kanji, action: :read)
      define(:get_kanji_by_id, args: [:id], action: :get_by_id, get?: true)
      define(:create_kanji, action: :create)
      define(:get_kanji_by_offset, args: [:offset], action: :by_offset, get?: true)
      define(:list_kanjis, action: :list_all)
      define(:get_kanji_by_character, args: [:character], action: :get_by_character, get?: true)
      define(:count_all_kanjis, action: :count_all)
    end

    resource(KumaSanKanji.Kanji.Meaning) do
      define(:create_meaning, action: :create)
      define(:list_meanings_by_kanji, action: :read)
      define(:get_meaning_by_kanji_and_value, action: :by_kanji_and_value)
    end

    resource(KumaSanKanji.Kanji.Pronunciation) do
      define(:create_pronunciation, action: :create)
      define(:list_pronunciations_by_kanji, action: :read)
      define(:get_pronunciation_by_kanji_and_value, action: :by_kanji_and_value)
    end

    resource(KumaSanKanji.Kanji.ExampleSentence) do
      define(:create_example_sentence, action: :create)
      define(:list_example_sentences_by_kanji, action: :read)
            define(:get_sentence_by_kanji_and_text, action: :by_kanji_and_text)
    end
    
    resource(KumaSanKanji.SRS.UserKanjiProgress)
  end

  # Helper function to count kanjis manually
  def count_all_kanjis!() do
    # Use a simple read action without any filtering or select options
    kanjis =
      KumaSanKanji.Kanji.Kanji
      |> Ash.read!(action: :count_all)

    length(kanjis)
  end
end
