# frozen_string_literal: true

FactoryBot.define do
  factory :territory do
    name { Faker::Address.country }

    trait :region do
      bassin_emploi { false }
      sequence(:code_region) { |n| "#{n}" }
    end
  end
end
