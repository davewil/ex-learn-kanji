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

    resource(KumaSanKanji.Kanji.Meaning)
    resource(KumaSanKanji.Kanji.Pronunciation)
    resource(KumaSanKanji.Kanji.ExampleSentence)
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
