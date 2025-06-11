defmodule KumaSanKanji.SRS.LogicTest do
  use KumaSanKanji.DataCase

  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.Kanji
  alias KumaSanKanji.Accounts.User

  describe "get_due_kanji/2" do
    setup do
      user = create_user()
      kanji = create_kanji()
      {:ok, user: user, kanji: kanji}
    end

    test "returns due kanji for a user", %{user: user, kanji: kanji} do
      # Initialize progress for the kanji
      {:ok, _progress} = Logic.initialize_progress(user.id, kanji.id)

      # Get due kanji
      {:ok, due_kanji} = Logic.get_due_kanji(user.id, 10)

      assert length(due_kanji) == 1
      assert hd(due_kanji).kanji_id == kanji.id
      assert hd(due_kanji).user_id == user.id
    end

    test "respects limit parameter", %{user: user} do
      # Create multiple kanji and initialize progress
      kanji_list = Enum.map(1..15, fn _i -> create_kanji() end)

      for kanji <- kanji_list do
        {:ok, _progress} = Logic.initialize_progress(user.id, kanji.id)
      end

      # Test limit enforcement
      {:ok, due_kanji} = Logic.get_due_kanji(user.id, 5)
      assert length(due_kanji) == 5
    end

    test "returns empty list when no kanji are due", %{user: user, kanji: kanji} do
      # Initialize progress with future review date
      # 1 hour from now
      future_date = DateTime.add(DateTime.utc_now(), 3600, :second)

      UserKanjiProgress
      |> Ash.Changeset.for_create(:create, %{
        user_id: user.id,
        kanji_id: kanji.id,
        next_review_date: future_date
      })
      |> Ash.create!()

      {:ok, due_kanji} = Logic.get_due_kanji(user.id, 10)
      assert due_kanji == []
    end
  end

  describe "record_review/3" do
    setup do
      user = create_user()
      kanji = create_kanji()
      {:ok, progress} = Logic.initialize_progress(user.id, kanji.id)
      {:ok, user: user, kanji: kanji, progress: progress}
    end

    test "successfully records a correct review", %{user: user, progress: progress} do
      {:ok, updated_progress} = Logic.record_review(progress.id, :correct, user.id)

      assert updated_progress.last_result == :correct
      assert updated_progress.total_reviews == 1
      assert updated_progress.correct_reviews == 1
      assert updated_progress.repetitions == 1
    end

    test "successfully records an incorrect review", %{user: user, progress: progress} do
      {:ok, updated_progress} = Logic.record_review(progress.id, :incorrect, user.id)

      assert updated_progress.last_result == :incorrect
      assert updated_progress.total_reviews == 1
      assert updated_progress.correct_reviews == 0
      assert updated_progress.repetitions == 0
    end

    test "returns unauthorized for wrong user", %{kanji: _kanji, progress: progress} do
      other_user = create_user()

      {:error, :unauthorized} = Logic.record_review(progress.id, :correct, other_user.id)
    end

    test "returns not_found for non-existent progress" do
      user = create_user()
      fake_id = Ash.UUID.generate()

      {:error, :not_found} = Logic.record_review(fake_id, :correct, user.id)
    end
  end

  describe "initialize_progress/2" do
    setup do
      user = create_user()
      kanji = create_kanji()
      {:ok, user: user, kanji: kanji}
    end

    test "creates new progress record", %{user: user, kanji: kanji} do
      {:ok, progress} = Logic.initialize_progress(user.id, kanji.id)

      assert progress.user_id == user.id
      assert progress.kanji_id == kanji.id
      assert progress.interval == 1
      assert progress.repetitions == 0
      assert Decimal.eq?(progress.ease_factor, Decimal.new("2.5"))
    end

    test "returns existing progress if already initialized", %{user: user, kanji: kanji} do
      {:ok, progress1} = Logic.initialize_progress(user.id, kanji.id)
      {:ok, progress2} = Logic.initialize_progress(user.id, kanji.id)

      assert progress1.id == progress2.id
    end

    test "returns error for non-existent kanji", %{user: user} do
      fake_kanji_id = Ash.UUID.generate()

      {:error, :kanji_not_found} = Logic.initialize_progress(user.id, fake_kanji_id)
    end
  end

  describe "get_user_stats/1" do
    setup do
      user = create_user()
      {:ok, user: user}
    end

    test "returns correct stats for user with no progress", %{user: user} do
      {:ok, stats} = Logic.get_user_stats(user.id)

      assert stats.total_kanji == 0
      assert stats.due_today == 0
      assert stats.total_reviews == 0
      assert stats.correct_reviews == 0
      assert stats.accuracy == 0.0
    end

    test "calculates stats correctly with progress data", %{user: user} do
      # Create some kanji and initialize progress
      kanji1 = create_kanji()
      kanji2 = create_kanji()

      {:ok, progress1} = Logic.initialize_progress(user.id, kanji1.id)
      {:ok, progress2} = Logic.initialize_progress(user.id, kanji2.id)

      # Record some reviews
      {:ok, _} = Logic.record_review(progress1.id, :correct, user.id)
      {:ok, _} = Logic.record_review(progress2.id, :incorrect, user.id)

      {:ok, stats} = Logic.get_user_stats(user.id)

      assert stats.total_kanji == 2
      assert stats.total_reviews == 2
      assert stats.correct_reviews == 1
      assert stats.accuracy == 50.0
    end
  end

  describe "bulk_initialize_progress/2" do
    setup do
      user = create_user()
      {:ok, user: user}
    end

    test "initializes progress for multiple kanji", %{user: user} do
      kanji_list = Enum.map(1..5, fn _i -> create_kanji() end)
      kanji_ids = Enum.map(kanji_list, & &1.id)

      {:ok, progress_list} = Logic.bulk_initialize_progress(user.id, kanji_ids)

      assert length(progress_list) == 5

      for progress <- progress_list do
        assert progress.user_id == user.id
        assert progress.kanji_id in kanji_ids
      end
    end

    test "returns error when too many kanji provided", %{user: user} do
      # Create 101 fake kanji IDs
      kanji_ids = Enum.map(1..101, fn _i -> Ash.UUID.generate() end)

      {:error, :too_many_kanji} = Logic.bulk_initialize_progress(user.id, kanji_ids)
    end
  end

  # Helper functions for test setup
  defp create_user do
    User
    |> Ash.Changeset.for_create(:create, %{
      email: "test#{System.unique_integer()}@example.com",
      username: "testuser#{System.unique_integer()}",
      hashed_password: Pbkdf2.hash_pwd_salt("password123")
    })
    |> Ash.create!()
  end

  defp create_kanji do
    character = "テ#{System.unique_integer()}"

    Kanji.create!(%{
      character: character,
      grade: 1,
      jlpt_level: 5,
      stroke_count: 5
    })
  end
end
