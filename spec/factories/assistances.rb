# frozen_string_literal: true

FactoryBot.define do
  factory :skill do
    title { Faker::Lorem.sentence }

    association :question

    trait :with_expert do
      after(:create) do |skill|
        FactoryBot.create :expert_skill, skill: skill
      end
    end
  end
end
