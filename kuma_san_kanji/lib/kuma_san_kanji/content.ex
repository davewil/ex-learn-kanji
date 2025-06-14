defmodule KumaSanKanji.Content do
  @moduledoc """
  The Content domain for the application.

  This domain handles content-related resources such as thematic groups,
  educational contexts, and learning metadata.
  """
  use Ash.Domain,
    extensions: [
      Ash.Extensions.ChangeTracking
    ],
    # Explicitly alias resources to ensure they're loaded
    validate_domain_config?: Mix.env() != :test

  alias KumaSanKanji.Content.ThematicGroup
  alias KumaSanKanji.Content.KanjiThematicGroup
  alias KumaSanKanji.Content.EducationalContext
  alias KumaSanKanji.Content.KanjiUsageExample
  alias KumaSanKanji.Content.KanjiLearningMeta

  resources do
    # Order resources based on dependency hierarchy
    resource(ThematicGroup)
    resource(EducationalContext)
    resource(KanjiUsageExample)
    resource(KanjiLearningMeta)
    resource(KanjiThematicGroup)
  end
end
