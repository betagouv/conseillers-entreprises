# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need

    trait :with_expert_skill do
      association :expert_skill
    end
  end
end
