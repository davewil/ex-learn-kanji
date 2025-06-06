defmodule KumaSanKanji.Seeds do
  @moduledoc """
  Seeds for the Kuma-san Kanji application.
  """

  alias KumaSanKanji.Kanji.Meaning
  alias KumaSanKanji.Kanji.Pronunciation
  alias KumaSanKanji.Kanji.ExampleSentence
  alias KumaSanKanji.Domain

  def seed_all do
    # Seed Kanji data
    insert_initial_data()
    # Seed Content data
    KumaSanKanji.Content.Seeds.insert_initial_data()
  end

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
      },
      %{
        character: "一",
        grade: 1,
        stroke_count: 1,
        jlpt_level: 5,
        meanings: [
          %{value: "one", is_primary: true},
          %{value: "first"}
        ],
        pronunciations: [
          %{value: "ひと", type: "kun", romaji: "hito"},
          %{value: "イチ", type: "on", romaji: "ichi"}
        ],
        example_sentences: [
          %{
            japanese: "一人で行きました。",
            translation: "I went alone."
          },
          %{
            japanese: "一番好きな食べ物は何ですか。",
            translation: "What is your favorite food?"
          }
        ]
      },
      %{
        character: "二",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "two", is_primary: true},
          %{value: "second"}
        ],
        pronunciations: [
          %{value: "ふた", type: "kun", romaji: "futa"},
          %{value: "ニ", type: "on", romaji: "ni"}
        ],
        example_sentences: [
          %{
            japanese: "二人で映画を見ました。",
            translation: "We watched a movie together (two people)."
          },
          %{
            japanese: "二階に住んでいます。",
            translation: "I live on the second floor."
          }
        ]
      },
      %{
        character: "三",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "three", is_primary: true}
        ],
        pronunciations: [
          %{value: "み", type: "kun", romaji: "mi"},
          %{value: "みっ", type: "kun", romaji: "mit"},
          %{value: "サン", type: "on", romaji: "san"}
        ],
        example_sentences: [
          %{
            japanese: "三時に会いましょう。",
            translation: "Let's meet at three o'clock."
          },
          %{
            japanese: "三日後に帰ります。",
            translation: "I will return in three days."
          }
        ]
      },
      %{
        character: "四",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "four", is_primary: true}
        ],
        pronunciations: [
          %{value: "よ", type: "kun", romaji: "yo"},
          %{value: "よん", type: "kun", romaji: "yon"},
          %{value: "シ", type: "on", romaji: "shi"}
        ],
        example_sentences: [
          %{
            japanese: "四時に起きます。",
            translation: "I wake up at four o'clock."
          },
          %{
            japanese: "家族は四人です。",
            translation: "My family has four people."
          }
        ]
      },
      %{
        character: "五",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "five", is_primary: true}
        ],
        pronunciations: [
          %{value: "いつ", type: "kun", romaji: "itsu"},
          %{value: "ゴ", type: "on", romaji: "go"}
        ],
        example_sentences: [
          %{
            japanese: "五時に家に帰ります。",
            translation: "I go home at five o'clock."
          },
          %{
            japanese: "私には五人兄弟がいます。",
            translation: "I have five siblings."
          }
        ]
      },
      %{
        character: "六",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "six", is_primary: true}
        ],
        pronunciations: [
          %{value: "む", type: "kun", romaji: "mu"},
          %{value: "むっ", type: "kun", romaji: "mut"},
          %{value: "ロク", type: "on", romaji: "roku"}
        ],
        example_sentences: [
          %{
            japanese: "六時に夕食を食べます。",
            translation: "I eat dinner at six o'clock."
          },
          %{
            japanese: "六月に日本へ行きます。",
            translation: "I'm going to Japan in June."
          }
        ]
      },
      %{
        character: "七",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "seven", is_primary: true}
        ],
        pronunciations: [
          %{value: "なな", type: "kun", romaji: "nana"},
          %{value: "シチ", type: "on", romaji: "shichi"}
        ],
        example_sentences: [
          %{
            japanese: "七時に寝ます。",
            translation: "I go to bed at seven o'clock."
          },
          %{
            japanese: "七月は暑いです。",
            translation: "July is hot."
          }
        ]
      },
      %{
        character: "八",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "eight", is_primary: true}
        ],
        pronunciations: [
          %{value: "や", type: "kun", romaji: "ya"},
          %{value: "よう", type: "kun", romaji: "you"},
          %{value: "ハチ", type: "on", romaji: "hachi"}
        ],
        example_sentences: [
          %{
            japanese: "八時に学校が始まります。",
            translation: "School starts at eight o'clock."
          },
          %{
            japanese: "八月は夏休みです。",
            translation: "August is summer vacation."
          }
        ]
      },
      %{
        character: "九",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "nine", is_primary: true}
        ],
        pronunciations: [
          %{value: "ここの", type: "kun", romaji: "kokono"},
          %{value: "キュウ", type: "on", romaji: "kyuu"},
          %{value: "ク", type: "on", romaji: "ku"}
        ],
        example_sentences: [
          %{
            japanese: "九時に起きます。",
            translation: "I wake up at nine o'clock."
          },
          %{
            japanese: "私は九歳です。",
            translation: "I am nine years old."
          }
        ]
      },
      %{
        character: "十",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "ten", is_primary: true}
        ],
        pronunciations: [
          %{value: "とお", type: "kun", romaji: "too"},
          %{value: "ジュウ", type: "on", romaji: "juu"}
        ],
        example_sentences: [
          %{
            japanese: "十時に寝ます。",
            translation: "I go to sleep at ten o'clock."
          },
          %{
            japanese: "十月は秋です。",
            translation: "October is autumn."
          }
        ]
      },
      %{
        character: "口",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "mouth", is_primary: true},
          %{value: "opening"}
        ],
        pronunciations: [
          %{value: "くち", type: "kun", romaji: "kuchi"},
          %{value: "コウ", type: "on", romaji: "kou"},
          %{value: "ク", type: "on", romaji: "ku"}
        ],
        example_sentences: [
          %{
            japanese: "口を開けてください。",
            translation: "Please open your mouth."
          },
          %{
            japanese: "日本語で言うと、口が難しいです。",
            translation: "When speaking Japanese, pronunciation is difficult."
          }
        ]
      },
      %{
        character: "目",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "eye", is_primary: true},
          %{value: "sight"}
        ],
        pronunciations: [
          %{value: "め", type: "kun", romaji: "me"},
          %{value: "モク", type: "on", romaji: "moku"}
        ],
        example_sentences: [
          %{
            japanese: "目が痛いです。",
            translation: "My eyes hurt."
          },
          %{
            japanese: "大きな目をしています。",
            translation: "He/She has big eyes."
          }
        ]
      },
      %{
        character: "耳",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "ear", is_primary: true}
        ],
        pronunciations: [
          %{value: "みみ", type: "kun", romaji: "mimi"},
          %{value: "ジ", type: "on", romaji: "ji"}
        ],
        example_sentences: [
          %{
            japanese: "耳が聞こえません。",
            translation: "I can't hear (my ears don't work)."
          },
          %{
            japanese: "彼女は小さい耳をしています。",
            translation: "She has small ears."
          }
        ]
      },
      %{
        character: "手",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "hand", is_primary: true},
          %{value: "arm"}
        ],
        pronunciations: [
          %{value: "て", type: "kun", romaji: "te"},
          %{value: "た", type: "kun", romaji: "ta"},
          %{value: "シュ", type: "on", romaji: "shu"}
        ],
        example_sentences: [
          %{
            japanese: "手を洗ってください。",
            translation: "Please wash your hands."
          },
          %{
            japanese: "手紙を書きます。",
            translation: "I'm writing a letter."
          }
        ]
      },
      %{
        character: "足",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "foot", is_primary: true},
          %{value: "leg"}
        ],
        pronunciations: [
          %{value: "あし", type: "kun", romaji: "ashi"},
          %{value: "た", type: "kun", romaji: "ta"},
          %{value: "ソク", type: "on", romaji: "soku"}
        ],
        example_sentences: [
          %{
            japanese: "足が痛いです。",
            translation: "My foot/leg hurts."
          },
          %{
            japanese: "足りません。",
            translation: "It's not enough."
          }
        ]
      },
      %{
        character: "上",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "above", is_primary: true},
          %{value: "up"},
          %{value: "top"}
        ],
        pronunciations: [
          %{value: "うえ", type: "kun", romaji: "ue"},
          %{value: "あ", type: "kun", romaji: "a"},
          %{value: "のぼ", type: "kun", romaji: "nobo"},
          %{value: "ジョウ", type: "on", romaji: "jou"},
          %{value: "ショウ", type: "on", romaji: "shou"}
        ],
        example_sentences: [
          %{
            japanese: "机の上に本があります。",
            translation: "There is a book on the desk."
          },
          %{
            japanese: "上手ですね。",
            translation: "You're good at it."
          }
        ]
      },
      %{
        character: "下",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "below", is_primary: true},
          %{value: "down"},
          %{value: "under"}
        ],
        pronunciations: [
          %{value: "した", type: "kun", romaji: "shita"},
          %{value: "さ", type: "kun", romaji: "sa"},
          %{value: "カ", type: "on", romaji: "ka"},
          %{value: "ゲ", type: "on", romaji: "ge"}
        ],
        example_sentences: [
          %{
            japanese: "机の下に猫がいます。",
            translation: "There is a cat under the desk."
          },
          %{
            japanese: "下に行きましょう。",
            translation: "Let's go downstairs."
          }
        ]
      },
      %{
        character: "右",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "right", is_primary: true},
          %{value: "right side"}
        ],
        pronunciations: [
          %{value: "みぎ", type: "kun", romaji: "migi"},
          %{value: "ウ", type: "on", romaji: "u"},
          %{value: "ユウ", type: "on", romaji: "yuu"}
        ],
        example_sentences: [
          %{
            japanese: "右に曲がってください。",
            translation: "Please turn right."
          },
          %{
            japanese: "右手で書きます。",
            translation: "I write with my right hand."
          }
        ]
      },
      %{
        character: "左",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "left", is_primary: true},
          %{value: "left side"}
        ],
        pronunciations: [
          %{value: "ひだり", type: "kun", romaji: "hidari"},
          %{value: "サ", type: "on", romaji: "sa"},
          %{value: "シャ", type: "on", romaji: "sha"}
        ],
        example_sentences: [
          %{
            japanese: "左に曲がってください。",
            translation: "Please turn left."
          },
          %{
            japanese: "左手で書くことができます。",
            translation: "I can write with my left hand."
          }
        ]
      },
      %{
        character: "中",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "middle", is_primary: true},
          %{value: "inside"},
          %{value: "center"}
        ],
        pronunciations: [
          %{value: "なか", type: "kun", romaji: "naka"},
          %{value: "チュウ", type: "on", romaji: "chuu"}
        ],
        example_sentences: [
          %{
            japanese: "箱の中に何がありますか。",
            translation: "What is inside the box?"
          },
          %{
            japanese: "中国語を勉強しています。",
            translation: "I'm studying Chinese."
          }
        ]
      },

      # Add after the existing kanji entries (after "中")

      %{
        character: "大",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "big", is_primary: true},
          %{value: "large"}
        ],
        pronunciations: [
          %{value: "おお", type: "kun", romaji: "oo"},
          %{value: "ダイ", type: "on", romaji: "dai"},
          %{value: "タイ", type: "on", romaji: "tai"}
        ],
        example_sentences: [
          %{
            japanese: "大きな家に住んでいます。",
            translation: "I live in a big house."
          },
          %{
            japanese: "これは大切です。",
            translation: "This is important."
          }
        ]
      },
      %{
        character: "小",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "small", is_primary: true},
          %{value: "little"}
        ],
        pronunciations: [
          %{value: "ちい", type: "kun", romaji: "chii"},
          %{value: "こ", type: "kun", romaji: "ko"},
          %{value: "ショウ", type: "on", romaji: "shou"}
        ],
        example_sentences: [
          %{
            japanese: "小さな猫がいます。",
            translation: "There is a small cat."
          },
          %{
            japanese: "小学校に行きます。",
            translation: "I go to elementary school."
          }
        ]
      },
      %{
        character: "年",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "year", is_primary: true}
        ],
        pronunciations: [
          %{value: "とし", type: "kun", romaji: "toshi"},
          %{value: "ネン", type: "on", romaji: "nen"}
        ],
        example_sentences: [
          %{
            japanese: "今年は良い年です。",
            translation: "This year is a good year."
          },
          %{
            japanese: "去年日本に行きました。",
            translation: "I went to Japan last year."
          }
        ]
      },
      %{
        character: "出",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "exit", is_primary: true},
          %{value: "leave"},
          %{value: "go out"}
        ],
        pronunciations: [
          %{value: "で", type: "kun", romaji: "de"},
          %{value: "だ", type: "kun", romaji: "da"},
          %{value: "シュツ", type: "on", romaji: "shutsu"}
        ],
        example_sentences: [
          %{
            japanese: "家を出ます。",
            translation: "I leave the house."
          },
          %{
            japanese: "出口はどこですか？",
            translation: "Where is the exit?"
          }
        ]
      },
      %{
        character: "入",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "enter", is_primary: true},
          %{value: "insert"}
        ],
        pronunciations: [
          %{value: "い", type: "kun", romaji: "i"},
          %{value: "はい", type: "kun", romaji: "hai"},
          %{value: "ニュウ", type: "on", romaji: "nyuu"}
        ],
        example_sentences: [
          %{
            japanese: "学校に入ります。",
            translation: "I enter the school."
          },
          %{
            japanese: "入口はあそこです。",
            translation: "The entrance is over there."
          }
        ]
      },
      %{
        character: "生",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "life", is_primary: true},
          %{value: "birth"},
          %{value: "raw"}
        ],
        pronunciations: [
          %{value: "い", type: "kun", romaji: "i"},
          %{value: "う", type: "kun", romaji: "u"},
          %{value: "は", type: "kun", romaji: "ha"},
          %{value: "なま", type: "kun", romaji: "nama"},
          %{value: "セイ", type: "on", romaji: "sei"},
          %{value: "ショウ", type: "on", romaji: "shou"}
        ],
        example_sentences: [
          %{
            japanese: "私は学生です。",
            translation: "I am a student."
          },
          %{
            japanese: "生まれた国はどこですか。",
            translation: "Which country were you born in?"
          }
        ]
      },
      %{
        character: "花",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "flower", is_primary: true},
          %{value: "blossom"}
        ],
        pronunciations: [
          %{value: "はな", type: "kun", romaji: "hana"},
          %{value: "カ", type: "on", romaji: "ka"}
        ],
        example_sentences: [
          %{
            japanese: "きれいな花が咲いています。",
            translation: "Beautiful flowers are blooming."
          },
          %{
            japanese: "花を買いました。",
            translation: "I bought flowers."
          }
        ]
      },
      %{
        character: "百",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "hundred", is_primary: true}
        ],
        pronunciations: [
          %{value: "ひゃく", type: "on", romaji: "hyaku"}
        ],
        example_sentences: [
          %{
            japanese: "百円です。",
            translation: "It's 100 yen."
          },
          %{
            japanese: "この本は百ページあります。",
            translation: "This book has 100 pages."
          }
        ]
      },
      %{
        character: "本",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "book", is_primary: true},
          %{value: "origin"},
          %{value: "real"}
        ],
        pronunciations: [
          %{value: "もと", type: "kun", romaji: "moto"},
          %{value: "ホン", type: "on", romaji: "hon"}
        ],
        example_sentences: [
          %{
            japanese: "面白い本を読みます。",
            translation: "I read an interesting book."
          },
          %{
            japanese: "これは日本の本です。",
            translation: "This is a Japanese book."
          }
        ]
      },
      %{
        character: "名",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "name", is_primary: true},
          %{value: "famous"}
        ],
        pronunciations: [
          %{value: "な", type: "kun", romaji: "na"},
          %{value: "メイ", type: "on", romaji: "mei"},
          %{value: "ミョウ", type: "on", romaji: "myou"}
        ],
        example_sentences: [
          %{
            japanese: "あなたの名前は何ですか。",
            translation: "What is your name?"
          },
          %{
            japanese: "有名な場所です。",
            translation: "It's a famous place."
          }
        ]
      },

      # Add after the existing kanji entries (after "名")

      %{
        character: "田",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "rice field", is_primary: true},
          %{value: "paddy"}
        ],
        pronunciations: [
          %{value: "た", type: "kun", romaji: "ta"},
          %{value: "デン", type: "on", romaji: "den"}
        ],
        example_sentences: [
          %{
            japanese: "田んぼで働いています。",
            translation: "I'm working in the rice field."
          },
          %{
            japanese: "田舎に住んでいます。",
            translation: "I live in the countryside."
          }
        ]
      },
      %{
        character: "力",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "power", is_primary: true},
          %{value: "strength"},
          %{value: "energy"}
        ],
        pronunciations: [
          %{value: "ちから", type: "kun", romaji: "chikara"},
          %{value: "リョク", type: "on", romaji: "ryoku"},
          %{value: "リキ", type: "on", romaji: "riki"}
        ],
        example_sentences: [
          %{
            japanese: "力が強いです。",
            translation: "He/She is strong (has great strength)."
          },
          %{
            japanese: "全力で走りました。",
            translation: "I ran with all my might."
          }
        ]
      },
      %{
        character: "立",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "stand", is_primary: true},
          %{value: "rise"},
          %{value: "set up"}
        ],
        pronunciations: [
          %{value: "た", type: "kun", romaji: "ta"},
          %{value: "リツ", type: "on", romaji: "ritsu"}
        ],
        example_sentences: [
          %{
            japanese: "立ってください。",
            translation: "Please stand up."
          },
          %{
            japanese: "彼は立派な人です。",
            translation: "He is a respectable person."
          }
        ]
      },
      %{
        character: "文",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "writing", is_primary: true},
          %{value: "sentence"},
          %{value: "literature"}
        ],
        pronunciations: [
          %{value: "ふみ", type: "kun", romaji: "fumi"},
          %{value: "ブン", type: "on", romaji: "bun"},
          %{value: "モン", type: "on", romaji: "mon"}
        ],
        example_sentences: [
          %{
            japanese: "文を書きます。",
            translation: "I write a sentence."
          },
          %{
            japanese: "文学について勉強しています。",
            translation: "I'm studying literature."
          }
        ]
      },
      %{
        character: "石",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "stone", is_primary: true},
          %{value: "rock"}
        ],
        pronunciations: [
          %{value: "いし", type: "kun", romaji: "ishi"},
          %{value: "セキ", type: "on", romaji: "seki"},
          %{value: "シャク", type: "on", romaji: "shaku"}
        ],
        example_sentences: [
          %{
            japanese: "石を投げました。",
            translation: "I threw a stone."
          },
          %{
            japanese: "大きな石がありました。",
            translation: "There was a big rock."
          }
        ]
      },
      %{
        character: "空",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "sky", is_primary: true},
          %{value: "empty"},
          %{value: "air"}
        ],
        pronunciations: [
          %{value: "そら", type: "kun", romaji: "sora"},
          %{value: "から", type: "kun", romaji: "kara"},
          %{value: "あ", type: "kun", romaji: "a"},
          %{value: "クウ", type: "on", romaji: "kuu"}
        ],
        example_sentences: [
          %{
            japanese: "空が青いです。",
            translation: "The sky is blue."
          },
          %{
            japanese: "このボックスは空です。",
            translation: "This box is empty."
          }
        ]
      },
      %{
        character: "車",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "car", is_primary: true},
          %{value: "vehicle"},
          %{value: "wheel"}
        ],
        pronunciations: [
          %{value: "くるま", type: "kun", romaji: "kuruma"},
          %{value: "シャ", type: "on", romaji: "sha"}
        ],
        example_sentences: [
          %{
            japanese: "新しい車を買いました。",
            translation: "I bought a new car."
          },
          %{
            japanese: "車で行きましょう。",
            translation: "Let's go by car."
          }
        ]
      },
      %{
        character: "森",
        grade: 1,
        stroke_count: 12,
        jlpt_level: 5,
        meanings: [
          %{value: "forest", is_primary: true},
          %{value: "woods"}
        ],
        pronunciations: [
          %{value: "もり", type: "kun", romaji: "mori"},
          %{value: "シン", type: "on", romaji: "shin"}
        ],
        example_sentences: [
          %{
            japanese: "森に行きました。",
            translation: "I went to the forest."
          },
          %{
            japanese: "森の中で道に迷いました。",
            translation: "I got lost in the forest."
          }
        ]
      },
      %{
        character: "金",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "gold", is_primary: true},
          %{value: "money"},
          %{value: "metal"}
        ],
        pronunciations: [
          %{value: "かね", type: "kun", romaji: "kane"},
          %{value: "かな", type: "kun", romaji: "kana"},
          %{value: "キン", type: "on", romaji: "kin"},
          %{value: "コン", type: "on", romaji: "kon"}
        ],
        example_sentences: [
          %{
            japanese: "金曜日に映画を見ます。",
            translation: "I watch a movie on Friday."
          },
          %{
            japanese: "金は重い金属です。",
            translation: "Gold is a heavy metal."
          }
        ]
      },
      %{
        character: "雨",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "rain", is_primary: true}
        ],
        pronunciations: [
          %{value: "あめ", type: "kun", romaji: "ame"},
          %{value: "あま", type: "kun", romaji: "ama"},
          %{value: "ウ", type: "on", romaji: "u"}
        ],
        example_sentences: [
          %{
            japanese: "今日は雨が降っています。",
            translation: "It's raining today."
          },
          %{
            japanese: "雨が止みました。",
            translation: "The rain has stopped."
          }
        ]
      },

      # Add after the existing kanji entries (after "雨")

      %{
        character: "天",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "heaven", is_primary: true},
          %{value: "sky"}
        ],
        pronunciations: [
          %{value: "あめ", type: "kun", romaji: "ame"},
          %{value: "あま", type: "kun", romaji: "ama"},
          %{value: "テン", type: "on", romaji: "ten"}
        ],
        example_sentences: [
          %{
            japanese: "天気が良いです。",
            translation: "The weather is good."
          },
          %{
            japanese: "天の川がきれいです。",
            translation: "The Milky Way is beautiful."
          }
        ]
      },
      %{
        character: "地",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "earth", is_primary: true},
          %{value: "ground"},
          %{value: "land"}
        ],
        pronunciations: [
          %{value: "チ", type: "on", romaji: "chi"},
          %{value: "ジ", type: "on", romaji: "ji"}
        ],
        example_sentences: [
          %{
            japanese: "地図を見ています。",
            translation: "I'm looking at a map."
          },
          %{
            japanese: "地震がありました。",
            translation: "There was an earthquake."
          }
        ]
      },
      %{
        character: "正",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "correct", is_primary: true},
          %{value: "right"},
          %{value: "justice"}
        ],
        pronunciations: [
          %{value: "ただ", type: "kun", romaji: "tada"},
          %{value: "まさ", type: "kun", romaji: "masa"},
          %{value: "セイ", type: "on", romaji: "sei"},
          %{value: "ショウ", type: "on", romaji: "shou"}
        ],
        example_sentences: [
          %{
            japanese: "正しい答えです。",
            translation: "That's the correct answer."
          },
          %{
            japanese: "正月は家族と過ごします。",
            translation: "I spend New Year's with my family."
          }
        ]
      },
      %{
        character: "先",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "ahead", is_primary: true},
          %{value: "previous"},
          %{value: "before"}
        ],
        pronunciations: [
          %{value: "さき", type: "kun", romaji: "saki"},
          %{value: "せん", type: "on", romaji: "sen"}
        ],
        example_sentences: [
          %{
            japanese: "先生に質問しました。",
            translation: "I asked the teacher a question."
          },
          %{
            japanese: "先に行ってください。",
            translation: "Please go ahead."
          }
        ]
      },
      %{
        character: "早",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "early", is_primary: true},
          %{value: "fast"}
        ],
        pronunciations: [
          %{value: "はや", type: "kun", romaji: "haya"},
          %{value: "サッ", type: "on", romaji: "sa"},
          %{value: "ソウ", type: "on", romaji: "sou"}
        ],
        example_sentences: [
          %{
            japanese: "早く起きます。",
            translation: "I wake up early."
          },
          %{
            japanese: "彼女は走るのが早いです。",
            translation: "She runs fast."
          }
        ]
      },
      %{
        character: "虫",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "insect", is_primary: true},
          %{value: "bug"}
        ],
        pronunciations: [
          %{value: "むし", type: "kun", romaji: "mushi"},
          %{value: "チュウ", type: "on", romaji: "chuu"}
        ],
        example_sentences: [
          %{
            japanese: "庭に虫がいます。",
            translation: "There are insects in the garden."
          },
          %{
            japanese: "子供は虫が好きです。",
            translation: "Children like insects."
          }
        ]
      },
      %{
        character: "字",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "character", is_primary: true},
          %{value: "letter"},
          %{value: "word"}
        ],
        pronunciations: [
          %{value: "あざ", type: "kun", romaji: "aza"},
          %{value: "ジ", type: "on", romaji: "ji"}
        ],
        example_sentences: [
          %{
            japanese: "この字を書いてください。",
            translation: "Please write this character."
          },
          %{
            japanese: "漢字を勉強しています。",
            translation: "I'm studying kanji characters."
          }
        ]
      },
      %{
        character: "町",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "town", is_primary: true},
          %{value: "block"}
        ],
        pronunciations: [
          %{value: "まち", type: "kun", romaji: "machi"},
          %{value: "チョウ", type: "on", romaji: "chou"}
        ],
        example_sentences: [
          %{
            japanese: "私の町は小さいです。",
            translation: "My town is small."
          },
          %{
            japanese: "静かな町に住んでいます。",
            translation: "I live in a quiet town."
          }
        ]
      },
      %{
        character: "村",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "village", is_primary: true}
        ],
        pronunciations: [
          %{value: "むら", type: "kun", romaji: "mura"},
          %{value: "ソン", type: "on", romaji: "son"}
        ],
        example_sentences: [
          %{
            japanese: "彼は小さな村から来ました。",
            translation: "He came from a small village."
          },
          %{
            japanese: "山の村に行きました。",
            translation: "I went to a mountain village."
          }
        ]
      },
      %{
        character: "男",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "man", is_primary: true},
          %{value: "male"}
        ],
        pronunciations: [
          %{value: "おとこ", type: "kun", romaji: "otoko"},
          %{value: "ダン", type: "on", romaji: "dan"},
          %{value: "ナン", type: "on", romaji: "nan"}
        ],
        example_sentences: [
          %{
            japanese: "彼は男の子です。",
            translation: "He is a boy."
          },
          %{
            japanese: "男性用のトイレはどこですか。",
            translation: "Where is the men's restroom?"
          }
        ]
      },

      # Add after the existing kanji entries (after "男")

      %{
        character: "女",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "woman", is_primary: true},
          %{value: "female"}
        ],
        pronunciations: [
          %{value: "おんな", type: "kun", romaji: "onna"},
          %{value: "め", type: "kun", romaji: "me"},
          %{value: "ジョ", type: "on", romaji: "jo"},
          %{value: "ニョ", type: "on", romaji: "nyo"},
          %{value: "ニョウ", type: "on", romaji: "nyou"}
        ],
        example_sentences: [
          %{
            japanese: "彼女は女の子です。",
            translation: "She is a girl."
          },
          %{
            japanese: "女性用のトイレはこちらです。",
            translation: "The women's restroom is this way."
          }
        ]
      },
      %{
        character: "子",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "child", is_primary: true},
          %{value: "kid"}
        ],
        pronunciations: [
          %{value: "こ", type: "kun", romaji: "ko"},
          %{value: "シ", type: "on", romaji: "shi"},
          %{value: "ス", type: "on", romaji: "su"}
        ],
        example_sentences: [
          %{
            japanese: "子供が公園で遊んでいます。",
            translation: "Children are playing in the park."
          },
          %{
            japanese: "彼女には二人の子供がいます。",
            translation: "She has two children."
          }
        ]
      },
      %{
        character: "学",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "study", is_primary: true},
          %{value: "learning"},
          %{value: "science"}
        ],
        pronunciations: [
          %{value: "まな", type: "kun", romaji: "mana"},
          %{value: "ガク", type: "on", romaji: "gaku"}
        ],
        example_sentences: [
          %{
            japanese: "学校に行きます。",
            translation: "I go to school."
          },
          %{
            japanese: "日本語を学んでいます。",
            translation: "I'm studying Japanese."
          }
        ]
      },
      %{
        character: "気",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "spirit", is_primary: true},
          %{value: "mind"},
          %{value: "air"}
        ],
        pronunciations: [
          %{value: "き", type: "kun", romaji: "ki"},
          %{value: "け", type: "kun", romaji: "ke"},
          %{value: "キ", type: "on", romaji: "ki"},
          %{value: "ケ", type: "on", romaji: "ke"}
        ],
        example_sentences: [
          %{
            japanese: "気をつけてください。",
            translation: "Please be careful."
          },
          %{
            japanese: "元気ですか？",
            translation: "How are you? (Are you well?)"
          }
        ]
      },
      %{
        character: "休",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "rest", is_primary: true},
          %{value: "break"},
          %{value: "holiday"}
        ],
        pronunciations: [
          %{value: "やす", type: "kun", romaji: "yasu"},
          %{value: "キュウ", type: "on", romaji: "kyuu"}
        ],
        example_sentences: [
          %{
            japanese: "今日は休みです。",
            translation: "Today is a day off."
          },
          %{
            japanese: "少し休みましょう。",
            translation: "Let's rest a little."
          }
        ]
      },
      %{
        character: "玉",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "jewel", is_primary: true},
          %{value: "ball"}
        ],
        pronunciations: [
          %{value: "たま", type: "kun", romaji: "tama"},
          %{value: "ギョク", type: "on", romaji: "gyoku"}
        ],
        example_sentences: [
          %{
            japanese: "玉を転がします。",
            translation: "I roll the ball."
          },
          %{
            japanese: "彼女はきれいな玉を持っています。",
            translation: "She has a beautiful jewel."
          }
        ]
      },
      %{
        character: "犬",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "dog", is_primary: true}
        ],
        pronunciations: [
          %{value: "いぬ", type: "kun", romaji: "inu"},
          %{value: "ケン", type: "on", romaji: "ken"}
        ],
        example_sentences: [
          %{
            japanese: "私は犬が好きです。",
            translation: "I like dogs."
          },
          %{
            japanese: "あの犬は大きいです。",
            translation: "That dog is big."
          }
        ]
      },
      %{
        character: "青",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "blue", is_primary: true},
          %{value: "green"}
        ],
        pronunciations: [
          %{value: "あお", type: "kun", romaji: "ao"},
          %{value: "セイ", type: "on", romaji: "sei"},
          %{value: "ショウ", type: "on", romaji: "shou"}
        ],
        example_sentences: [
          %{
            japanese: "空は青いです。",
            translation: "The sky is blue."
          },
          %{
            japanese: "青い服を着ています。",
            translation: "I'm wearing blue clothes."
          }
        ]
      },
      %{
        character: "赤",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "red", is_primary: true}
        ],
        pronunciations: [
          %{value: "あか", type: "kun", romaji: "aka"},
          %{value: "セキ", type: "on", romaji: "seki"},
          %{value: "シャク", type: "on", romaji: "shaku"}
        ],
        example_sentences: [
          %{
            japanese: "赤いリンゴを食べました。",
            translation: "I ate a red apple."
          },
          %{
            japanese: "彼女は赤いドレスを着ています。",
            translation: "She is wearing a red dress."
          }
        ]
      },
      %{
        character: "白",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "white", is_primary: true}
        ],
        pronunciations: [
          %{value: "しろ", type: "kun", romaji: "shiro"},
          %{value: "しら", type: "kun", romaji: "shira"},
          %{value: "ハク", type: "on", romaji: "haku"},
          %{value: "ビャク", type: "on", romaji: "byaku"}
        ],
        example_sentences: [
          %{
            japanese: "白い紙を使います。",
            translation: "I use white paper."
          },
          %{
            japanese: "白い雲が見えます。",
            translation: "I can see white clouds."
          }
        ]
      },

      # Add these entries before the closing bracket of kanji_list

      %{
        character: "円",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "circle", is_primary: true},
          %{value: "yen"},
          %{value: "round"}
        ],
        pronunciations: [
          %{value: "まる", type: "kun", romaji: "maru"},
          %{value: "エン", type: "on", romaji: "en"}
        ],
        example_sentences: [
          %{
            japanese: "これは百円です。",
            translation: "This is 100 yen."
          },
          %{
            japanese: "円を書きました。",
            translation: "I drew a circle."
          }
        ]
      },
      %{
        character: "王",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "king", is_primary: true},
          %{value: "ruler"}
        ],
        pronunciations: [
          %{value: "オウ", type: "on", romaji: "ou"}
        ],
        example_sentences: [
          %{
            japanese: "王様の話が好きです。",
            translation: "I like stories about kings."
          },
          %{
            japanese: "彼はチェスの王です。",
            translation: "He is the king of chess."
          }
        ]
      },
      %{
        character: "音",
        grade: 1,
        stroke_count: 9,
        jlpt_level: 5,
        meanings: [
          %{value: "sound", is_primary: true},
          %{value: "noise"}
        ],
        pronunciations: [
          %{value: "おと", type: "kun", romaji: "oto"},
          %{value: "ね", type: "kun", romaji: "ne"},
          %{value: "オン", type: "on", romaji: "on"}
        ],
        example_sentences: [
          %{
            japanese: "大きな音がしました。",
            translation: "There was a loud sound."
          },
          %{
            japanese: "音楽を聞いています。",
            translation: "I'm listening to music."
          }
        ]
      },
      %{
        character: "貝",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "shell", is_primary: true},
          %{value: "shellfish"}
        ],
        pronunciations: [
          %{value: "かい", type: "kun", romaji: "kai"},
          %{value: "バイ", type: "on", romaji: "bai"}
        ],
        example_sentences: [
          %{
            japanese: "海で貝を集めました。",
            translation: "I collected shells at the beach."
          },
          %{
            japanese: "この貝はきれいです。",
            translation: "This shell is beautiful."
          }
        ]
      },
      %{
        character: "校",
        grade: 1,
        stroke_count: 10,
        jlpt_level: 5,
        meanings: [
          %{value: "school", is_primary: true},
          %{value: "exam"}
        ],
        pronunciations: [
          %{value: "コウ", type: "on", romaji: "kou"}
        ],
        example_sentences: [
          %{
            japanese: "学校は9時に始まります。",
            translation: "School starts at 9 o'clock."
          },
          %{
            japanese: "私の学校は大きいです。",
            translation: "My school is big."
          }
        ]
      },
      %{
        character: "糸",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "thread", is_primary: true},
          %{value: "string"}
        ],
        pronunciations: [
          %{value: "いと", type: "kun", romaji: "ito"},
          %{value: "シ", type: "on", romaji: "shi"}
        ],
        example_sentences: [
          %{
            japanese: "この糸は赤いです。",
            translation: "This thread is red."
          },
          %{
            japanese: "糸で服を縫います。",
            translation: "I sew clothes with thread."
          }
        ]
      },
      %{
        character: "見",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "see", is_primary: true},
          %{value: "look"},
          %{value: "watch"}
        ],
        pronunciations: [
          %{value: "み", type: "kun", romaji: "mi"},
          %{value: "ケン", type: "on", romaji: "ken"}
        ],
        example_sentences: [
          %{
            japanese: "映画を見ました。",
            translation: "I watched a movie."
          },
          %{
            japanese: "見てください。",
            translation: "Please look."
          }
        ]
      },
      %{
        character: "千",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "thousand", is_primary: true}
        ],
        pronunciations: [
          %{value: "ち", type: "kun", romaji: "chi"},
          %{value: "セン", type: "on", romaji: "sen"}
        ],
        example_sentences: [
          %{
            japanese: "千円を払いました。",
            translation: "I paid 1000 yen."
          },
          %{
            japanese: "この本は千ページあります。",
            translation: "This book has 1000 pages."
          }
        ]
      },
      %{
        character: "夕",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "evening", is_primary: true}
        ],
        pronunciations: [
          %{value: "ゆう", type: "kun", romaji: "yuu"},
          %{value: "セキ", type: "on", romaji: "seki"}
        ],
        example_sentences: [
          %{
            japanese: "夕方に帰ります。",
            translation: "I'll return in the evening."
          },
          %{
            japanese: "夕日がきれいです。",
            translation: "The sunset is beautiful."
          }
        ]
      },
      %{
        character: "草",
        grade: 1,
        stroke_count: 9,
        jlpt_level: 5,
        meanings: [
          %{value: "grass", is_primary: true},
          %{value: "weed"},
          %{value: "herb"}
        ],
        pronunciations: [
          %{value: "くさ", type: "kun", romaji: "kusa"},
          %{value: "ソウ", type: "on", romaji: "sou"}
        ],
        example_sentences: [
          %{
            japanese: "草が青いです。",
            translation: "The grass is green."
          },
          %{
            japanese: "庭に草があります。",
            translation: "There is grass in the garden."
          }
        ]
      },
      %{
        character: "竹",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "bamboo", is_primary: true}
        ],
        pronunciations: [
          %{value: "たけ", type: "kun", romaji: "take"},
          %{value: "チク", type: "on", romaji: "chiku"}
        ],
        example_sentences: [
          %{
            japanese: "竹で作った箸です。",
            translation: "These are chopsticks made of bamboo."
          },
          %{
            japanese: "庭に竹を植えました。",
            translation: "I planted bamboo in the garden."
          }
        ]
      },
      %{
        character: "土",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "soil", is_primary: true},
          %{value: "earth"},
          %{value: "ground"}
        ],
        pronunciations: [
          %{value: "つち", type: "kun", romaji: "tsuchi"},
          %{value: "ド", type: "on", romaji: "do"},
          %{value: "ト", type: "on", romaji: "to"}
        ],
        example_sentences: [
          %{
            japanese: "土曜日に買い物に行きます。",
            translation: "I go shopping on Saturday."
          },
          %{
            japanese: "花を土に植えました。",
            translation: "I planted flowers in the soil."
          }
        ]
      },
      %{
        character: "林",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "grove", is_primary: true},
          %{value: "forest"}
        ],
        pronunciations: [
          %{value: "はやし", type: "kun", romaji: "hayashi"},
          %{value: "リン", type: "on", romaji: "rin"}
        ],
        example_sentences: [
          %{
            japanese: "林の中を散歩しました。",
            translation: "I took a walk in the grove."
          },
          %{
            japanese: "林さんは私の友達です。",
            translation: "Mr. Hayashi is my friend."
          }
        ]
      }
    ]

    # Insert each Kanji and its related data
    Enum.each(kanji_list, fn kanji_data ->
      # Use the domain to create the kanji
      {:ok, kanji} =
        Domain.create_kanji(
          Map.take(kanji_data, [:character, :grade, :stroke_count, :jlpt_level])
        )

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
