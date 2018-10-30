# frozen_string_literal: true

FactoryBot.define do
  factory :territory_city do
    association :commune
    association :territory
  end
end
