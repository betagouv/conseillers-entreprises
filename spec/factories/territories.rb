# frozen_string_literal: true

FactoryBot.define do
  factory :territory do
    name { Faker::Address.country }

    trait :region do
      bassin_emploi { false }
      code_region { Faker::Number.number(digits: 5) }
    end
  end
end
