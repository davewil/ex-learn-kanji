defmodule KumaSanKanji.Seeds do
  @moduledoc """
  Seeds for the Kuma-san Kanji application.
  """

  alias KumaSanKanji.Kanji.Kanji
  alias KumaSanKanji.Kanji.Meaning
  alias KumaSanKanji.Kanji.Pronunciation
  alias KumaSanKanji.Kanji.ExampleSentence

  def insert_initial_data do
    # List of Kanji with their data
    kanji_list = [
      %{
        character: "水",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "water", is_primary: true},
          %{value: "liquid"}
        ],
        pronunciations: [
          %{value: "みず", type: "kun", romaji: "mizu"},
          %{value: "スイ", type: "on", romaji: "sui"}
        ],
        example_sentences: [
          %{
            japanese: "水を飲みます。",
            translation: "I drink water."
          },
          %{
            japanese: "水曜日は水泳に行きます。",
            translation: "On Wednesday, I go swimming."
          }
        ]
      },
      %{
        character: "火",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "fire", is_primary: true},
          %{value: "flame"}
        ],
        pronunciations: [
          %{value: "ひ", type: "kun", romaji: "hi"},
          %{value: "カ", type: "on", romaji: "ka"}
        ],
        example_sentences: [
          %{
            japanese: "火をつけます。",
            translation: "I light a fire."
          },
          %{
            japanese: "火曜日に会議があります。",
            translation: "There is a meeting on Tuesday."
          }
        ]
      },
      %{
        character: "木",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "tree", is_primary: true},
          %{value: "wood"}
        ],
        pronunciations: [
          %{value: "き", type: "kun", romaji: "ki"},
          %{value: "モク", type: "on", romaji: "moku"}
        ],
        example_sentences: [
          %{
            japanese: "公園に木がたくさんあります。",
            translation: "There are many trees in the park."
          },
          %{
            japanese: "木曜日に授業があります。",
            translation: "I have class on Thursday."
          }
        ]
      },
      # Additional kanji
      %{
        character: "山",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "mountain", is_primary: true},
          %{value: "hill"}
        ],
        pronunciations: [
          %{value: "やま", type: "kun", romaji: "yama"},
          %{value: "サン", type: "on", romaji: "san"}
        ],
        example_sentences: [
          %{
            japanese: "富士山は日本で一番高い山です。",
            translation: "Mount Fuji is the highest mountain in Japan."
          },
          %{
            japanese: "週末に山に登ります。",
            translation: "I climb mountains on weekends."
          }
        ]
      },
      %{
        character: "川",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "river", is_primary: true},
          %{value: "stream"}
        ],
        pronunciations: [
          %{value: "かわ", type: "kun", romaji: "kawa"},
          %{value: "セン", type: "on", romaji: "sen"}
        ],
        example_sentences: [
          %{
            japanese: "川で泳ぐのは危険です。",
            translation: "Swimming in the river is dangerous."
          },
          %{
            japanese: "この川は長いです。",
            translation: "This river is long."
          }
        ]
      },
      %{
        character: "日",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "day", is_primary: true},
          %{value: "sun"},
          %{value: "Japan"}
        ],
        pronunciations: [
          %{value: "ひ", type: "kun", romaji: "hi"},
          %{value: "ニチ", type: "on", romaji: "nichi"},
          %{value: "ジツ", type: "on", romaji: "jitsu"}
        ],
        example_sentences: [
          %{
            japanese: "今日はいい日です。",
            translation: "Today is a good day."
          },
          %{
            japanese: "日本語を勉強しています。",
            translation: "I am studying Japanese."
          }
        ]
      },
      %{
        character: "月",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "month", is_primary: true},
          %{value: "moon"}
        ],
        pronunciations: [
          %{value: "つき", type: "kun", romaji: "tsuki"},
          %{value: "ゲツ", type: "on", romaji: "getsu"},
          %{value: "ガツ", type: "on", romaji: "gatsu"}
        ],
        example_sentences: [
          %{
            japanese: "月がきれいですね。",
            translation: "The moon is beautiful, isn't it?"
          },
          %{
            japanese: "来月日本に行きます。",
            translation: "I'm going to Japan next month."
          }
        ]
      },
      %{
        character: "人",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "person", is_primary: true},
          %{value: "human being"}
        ],
        pronunciations: [
          %{value: "ひと", type: "kun", romaji: "hito"},
          %{value: "ジン", type: "on", romaji: "jin"},
          %{value: "ニン", type: "on", romaji: "nin"}
        ],
        example_sentences: [
          %{
            japanese: "あの人は先生です。",
            translation: "That person is a teacher."
          },
          %{
            japanese: "日本人の友達がいます。",
            translation: "I have a Japanese friend."
          }
        ]
      }
    ]

    # Insert each Kanji and its related data
    Enum.each(kanji_list, fn kanji_data ->
      {:ok, kanji} =
        Kanji.create(Map.take(kanji_data, [:character, :grade, :stroke_count, :jlpt_level]))

      # Insert meanings
      Enum.each(kanji_data.meanings, fn meaning_data ->
        Meaning.create(Map.put(meaning_data, :kanji_id, kanji.id))
      end)

      # Insert pronunciations
      Enum.each(kanji_data.pronunciations, fn pronunciation_data ->
        Pronunciation.create(Map.put(pronunciation_data, :kanji_id, kanji.id))
      end)

      # Insert example sentences
      Enum.each(kanji_data.example_sentences, fn sentence_data ->
        ExampleSentence.create(Map.put(sentence_data, :kanji_id, kanji.id))
      end)
    end)
  end
end
