# frozen_string_literal: true

FactoryBot.define do
  factory :assistance do
    title { Faker::Lorem.sentence }

    association :question

    trait :with_expert do
      after(:create) do |assistance|
        FactoryBot.create :assistance_expert, assistance: assistance
      end
    end
  end
end
