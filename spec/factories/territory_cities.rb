# frozen_string_literal: true

FactoryGirl.define do
  factory :territory_city do
    city_code { Random.rand(10_000..90_000).to_s }
    association :territory
  end
end
