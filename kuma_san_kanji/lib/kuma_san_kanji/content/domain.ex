defmodule KumaSanKanji.Content.Domain do
  @moduledoc """
  Content domain for the application.
  
  This domain handles content-related resources such as thematic groups,
  educational contexts, and learning metadata.
  """
  use Ash.Domain
  resources do
    resource KumaSanKanji.Content.ThematicGroup do
      define :get_thematic_groups, action: :read
      define :get_ordered_groups, action: :ordered
      define :create_thematic_group, action: :create
    end
    
    resource KumaSanKanji.Content.KanjiThematicGroup do
      define :get_kanji_group_joins, action: :by_kanji
      define :get_group_kanji_joins, action: :by_group
      define :create_kanji_thematic_group, action: :create
    end
    
    resource KumaSanKanji.Content.KanjiUsageExample do
      define :get_kanji_usage_examples, action: :by_kanji
      define :create_kanji_usage_example, action: :create
    end
    
    resource KumaSanKanji.Content.KanjiLearningMeta do
      define :get_kanji_learning_meta, action: :by_kanji
      define :create_kanji_learning_meta, action: :create
    end
    
    resource KumaSanKanji.Content.EducationalContext do
      define :get_educational_context_by_grade, action: :by_grade_level
      define :create_educational_context, action: :create
    end
  end
end
