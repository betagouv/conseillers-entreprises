# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    need
    expert
    skill

    # Create a match in the legacy data format, with an expert_skill
    # but no direct relation to expert nor skill.
    trait :legacy do
      transient do
        expert_skill { nil }
      end

      after(:create) do |match, evaluator|
        # Use update_colums to bypass validation constraints
        match.update_columns({
          experts_skills_id: evaluator.expert_skill&.id,
          expert_id: nil,
          skill_id: nil
        })
      end
    end
  end
end
