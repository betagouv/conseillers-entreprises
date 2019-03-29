# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :diagnosed_need

    trait :with_expert_skill do
      association :expert_skill
    end

    trait :with_relay do
      association :relay
    end
  end
end
