# frozen_string_literal: true

FactoryBot.define do
  factory :territory_user do
    association :territory
    association :user
  end
end
