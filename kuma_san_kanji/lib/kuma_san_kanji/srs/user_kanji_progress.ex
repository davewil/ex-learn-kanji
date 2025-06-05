defmodule KumaSanKanji.SRS.UserKanjiProgress do
  @moduledoc """
  Tracks each user's kanji review progress for the Spaced Repetition System (SRS).

  Implements the SM-2 algorithm for calculating review intervals based on user performance.
  Ensures secure access control - users can only access/modify their own progress.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key(:id)

    # SRS state tracking
    attribute(:next_review_date, :utc_datetime, allow_nil?: false)
    # Days between reviews
    attribute(:interval, :integer, default: 1, allow_nil?: false)
    # SM-2 ease factor
    attribute(:ease_factor, :decimal, default: Decimal.new("2.5"), allow_nil?: false)
    # Successful repetitions count
    attribute(:repetitions, :integer, default: 0, allow_nil?: false)
    # :correct, :incorrect, :skip
    attribute(:last_result, :atom, allow_nil?: true)

    # Tracking metadata
    attribute(:first_reviewed_at, :utc_datetime, allow_nil?: true)
    attribute(:last_reviewed_at, :utc_datetime, allow_nil?: true)
    attribute(:total_reviews, :integer, default: 0, allow_nil?: false)
    attribute(:correct_reviews, :integer, default: 0, allow_nil?: false)

    timestamps()
  end

  relationships do
    belongs_to(:user, KumaSanKanji.Accounts.User,
      allow_nil?: false,
      define_attribute?: true
    )

    belongs_to(:kanji, KumaSanKanji.Kanji.Kanji,
      allow_nil?: false,
      define_attribute?: true
    )
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([:user_id, :kanji_id, :next_review_date, :interval, :ease_factor, :repetitions])

      change(fn changeset, _context ->
        # Set initial review date to now if not provided
        case Ash.Changeset.get_attribute(changeset, :next_review_date) do
          nil -> Ash.Changeset.change_attribute(changeset, :next_review_date, DateTime.utc_now())
          _ -> changeset
        end
      end)
    end

    # Custom action to initialize progress for a user-kanji pair
    create :initialize do
      accept([:user_id, :kanji_id])

      change(fn changeset, _context ->
        changeset
        |> Ash.Changeset.change_attribute(:next_review_date, DateTime.utc_now())
        |> Ash.Changeset.change_attribute(:interval, 1)
        |> Ash.Changeset.change_attribute(:ease_factor, Decimal.new("2.5"))
        |> Ash.Changeset.change_attribute(:repetitions, 0)
      end)
    end

    # Action to record a review result and update SRS state
    update :record_review do
      accept([:last_result])

      change(fn changeset, _context ->
        KumaSanKanji.SRS.UserKanjiProgress.update_srs_state(changeset)
      end)
    end

    # Read action to get progress for a specific user-kanji pair
    read :get_user_kanji_progress do
      argument(:user_id, :uuid, allow_nil?: false)
      argument(:kanji_id, :uuid, allow_nil?: false)

      filter(expr(user_id == ^arg(:user_id) and kanji_id == ^arg(:kanji_id)))
    end

    # Read action to get kanji due for review for a user
    read :due_for_review do
      argument(:user_id, :uuid, allow_nil?: false)
      argument(:limit, :integer, default: 10)

      # Compare next_review_date directly to now (assumes ISO8601/UTC)
      filter(expr(user_id == ^arg(:user_id) and next_review_date <= ^DateTime.utc_now()))

      prepare(fn query, _context ->
        query
        |> Ash.Query.sort(:next_review_date)
        |> Ash.Query.limit(Map.get(query.arguments, :limit, 10))
      end)
    end

    # Read action to get user's progress stats
    read :user_stats do
      argument(:user_id, :uuid, allow_nil?: false)

      filter(expr(user_id == ^arg(:user_id)))
    end
  end

  # Note: Authorization will be handled at the application level 
  # since the base User resource doesn't use Ash policies

  code_interface do
    define(:create, action: :create)
    define(:initialize, action: :initialize)
    define(:record_review, action: :record_review)
    define(:get_user_kanji_progress, action: :get_user_kanji_progress)
    define(:due_for_review, action: :due_for_review)
    define(:user_stats, action: :user_stats)
  end

  identities do
    # Prevent duplicate progress entries for the same user/kanji
    identity(:unique_user_kanji, [:user_id, :kanji_id])
  end

  sqlite do
    table("user_kanji_progress")
    repo(KumaSanKanji.Repo)
  end

  @doc """
  Updates SRS state based on review result using the SM-2 algorithm.

  This function implements the core SRS logic:
  - Correct answers increase interval and may increase ease factor
  - Incorrect answers reset interval to 1 and decrease ease factor
  - Ease factor is clamped to minimum of 1.3
  """
  def update_srs_state(changeset) do
    current_time = DateTime.utc_now()
    result = Ash.Changeset.get_attribute(changeset, :last_result)

    # Get current values from the changeset data
    current_interval = Ash.Changeset.get_attribute(changeset, :interval) || 1

    current_ease_factor =
      Ash.Changeset.get_attribute(changeset, :ease_factor) || Decimal.new("2.5")

    current_repetitions = Ash.Changeset.get_attribute(changeset, :repetitions) || 0
    current_total_reviews = Ash.Changeset.get_attribute(changeset, :total_reviews) || 0
    current_correct_reviews = Ash.Changeset.get_attribute(changeset, :correct_reviews) || 0

    # Calculate new values based on result
    {new_interval, new_ease_factor, new_repetitions, new_correct_count} =
      case result do
        :correct ->
          new_repetitions = current_repetitions + 1
          new_correct_count = current_correct_reviews + 1

          # SM-2 algorithm for correct answers
          {new_interval, new_ease_factor} =
            calculate_sm2_interval(
              current_interval,
              current_ease_factor,
              new_repetitions,
              # Quality of response (5 = perfect)
              5
            )

          {new_interval, new_ease_factor, new_repetitions, new_correct_count}

        :incorrect ->
          # Reset on incorrect answer
          new_ease_factor =
            Decimal.max(
              Decimal.sub(current_ease_factor, Decimal.new("0.2")),
              Decimal.new("1.3")
            )

          {1, new_ease_factor, 0, current_correct_reviews}

        :skip ->
          # Skip doesn't affect SRS state much, just updates review date slightly
          {max(1, div(current_interval, 2)), current_ease_factor, current_repetitions,
           current_correct_reviews}
      end

    # Calculate next review date and format for SQLite
    next_review_date =
      current_time
      |> DateTime.add(new_interval * 24 * 60 * 60, :second)
      |> DateTime.to_naive()
      |> NaiveDateTime.to_string()
      |> String.replace(" ", "T")

    changeset
    |> Ash.Changeset.change_attribute(:last_result, result)
    |> Ash.Changeset.change_attribute(:interval, new_interval)
    |> Ash.Changeset.change_attribute(:ease_factor, new_ease_factor)
    |> Ash.Changeset.change_attribute(:repetitions, new_repetitions)
    |> Ash.Changeset.change_attribute(:next_review_date, next_review_date)
    |> Ash.Changeset.change_attribute(:last_reviewed_at, current_time)
    |> Ash.Changeset.change_attribute(:total_reviews, current_total_reviews + 1)
    |> Ash.Changeset.change_attribute(:correct_reviews, new_correct_count)
    |> maybe_set_first_reviewed_at(current_time)
  end

  defp maybe_set_first_reviewed_at(changeset, current_time) do
    case Ash.Changeset.get_attribute(changeset, :first_reviewed_at) do
      nil -> Ash.Changeset.change_attribute(changeset, :first_reviewed_at, current_time)
      _ -> changeset
    end
  end

  @doc """
  Implements the SM-2 algorithm for calculating review intervals.

  ## Parameters
  - interval: Current interval in days
  - ease_factor: Current ease factor (should be >= 1.3)
  - repetitions: Number of successful repetitions
  - quality: Quality of response (0-5, where 5 is perfect)

  ## Returns
  {new_interval, new_ease_factor}
  """
  def calculate_sm2_interval(interval, ease_factor, repetitions, quality) do
    # Convert ease_factor to float for calculation
    ef = Decimal.to_float(ease_factor)

    # Calculate new ease factor
    new_ef = ef + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
    # Minimum ease factor is 1.3
    new_ef = max(new_ef, 1.3)

    # Calculate new interval
    new_interval =
      case repetitions do
        1 -> 1
        2 -> 6
        n when n > 2 -> round(interval * new_ef)
        _ -> 1
      end

    {new_interval, Decimal.from_float(new_ef)}
  end
end
