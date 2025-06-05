defmodule KumaSanKanji.Domain do
  use Ash.Domain

  resources do
    resource(KumaSanKanji.Accounts.User)
    resource(KumaSanKanji.Kanji.Kanji)
    resource(KumaSanKanji.Kanji.Meaning)
    resource(KumaSanKanji.Kanji.Pronunciation)
    resource(KumaSanKanji.Kanji.ExampleSentence)
    resource(KumaSanKanji.SRS.UserKanjiProgress)
  end
end
