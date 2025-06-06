# WaniKani's SRS Stages

WaniKani’s SRS spans across nine stages, which are split across five groups.

WaniKani's SRS

Apprentice → Guru → Master → Enlightened → Burned

Apprentice consists of the first four SRS stages. Guru consists of two stages. Master, Enlightened, and Burned represent single stages.

In order to reach Guru from Apprentice, you must get an item to stage 5 on the SRS scale. If you get an item correct, it goes up one stage. If you get an item incorrect, it goes down one or more stages, depending on how far along you are, the type of review (radical, kanji, or vocabulary), and how many times you answer the review incorrectly.

The lowest stage is stage 1, so even if you answer something incorrectly a ton, that’s as far down the scale as it will go.

How does it work?
How are the SRS stage decrement calculated? The following formula is used:

new_srs_stage = current_srs_stage - (incorrect_adjustment_count * srs_penalty_factor)

incorrect_adjustment_count is the number of incorrect times you have answered divided by two and rounded up. srs_penalty_factor is 2 if the current_srs_stage is at or above 5. Otherwise it is 1.

Let’s pretend you are trying to get the kanji 大 to guru, and you’ve already learned 大 during lessons. Here are your answers:

Correct (+1 stage, so it’s now at SRS stage 2)
Correct (+1 stage, SRS stage 3)
Correct (+1 stage, SRS stage 4)
Incorrect once before getting it correct (-1 stage, SRS stage 3)
Correct (+1 stage, SRS stage 4)
Correct (+1 stage, SRS stage 5 GURU)
Correct (+1 stage, SRS stage 6)
Incorrect three times before getting it correct (-4 stage, SRS stage 2)
When an item reaches Guru, that means you know that item fairly well, but not great. Enough to unlock available associated items, like kanji that use a radical, or vocabulary that use a kanji, etc.

What do Guru, Master, Enlightened, and Burned mean?#
Guru: You know an item fairly well. Any available, associated items will unlock and appear in your Lessons queue.

Master: You should be able to recall these items without using the mnemonics, usually.

Enlightened: You should be able to recall these items without the mnemonic, fairly quickly. The answer should appear without much effort.

Burned: This item is “fluent” in your brain. The answer comes with little-to-no effort. You will remember this item for a long, long time. Even if you don’t use it and “forget” it sometime in the future, it should come back to you quickly after recalling it. Items that are “burned” no longer show up in reviews. You can unburn an item on an item’s individual page, which returns the item to Apprentice.

What are actual SRS timings?#
Our timing intervals are meant to fall just before you’ll forget the item.

Once you finish the Lesson for an item it becomes Apprentice 1. There is a 4 hour wait until that item appears in your Reviews. If you get that Review correct, the item moves up to Apprentice 2, and your wait is now 8 hours.

Apprentice 1 → 4 hours → Apprentice 2
Apprentice 2 → 8 hours → Apprentice 3
Apprentice 3 → 1 day → Apprentice 4
Apprentice 4 → 2 days → Guru 1
Guru 1 → 1 week → Guru 2
Guru 2 → 2 weeks → Master
Master → 1 month → Enlightened
Enlightened → 4 months → Burned

For Level 1 & 2 the SRS timings are accelerated for the Apprentice stage.

Apprentice 1 → 2 hours → Apprentice 2
Apprentice 2 → 4 hours → Apprentice 3
Apprentice 3 → 8 hours → Apprentice 4
Apprentice 4 → 1 day → Guru 1

Review times are also rounded down to the beginning of the hour, so you won’t get new reviews every couple minutes. Instead, you’ll get (hopefully) a nice manageable chunk.
