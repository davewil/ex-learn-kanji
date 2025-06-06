defmodule KumaSanKanji.Domain do
  use Ash.Domain

  resources do
    resource(KumaSanKanji.Accounts.User)
    resource(KumaSanKanji.Kanji.Kanji) do
      define :read_kanji, action: :read
    end
    resource(KumaSanKanji.Kanji.Meaning)
    resource(KumaSanKanji.Kanji.Pronunciation)
    resource(KumaSanKanji.Kanji.ExampleSentence)
    resource(KumaSanKanji.SRS.UserKanjiProgress)
  end
end
