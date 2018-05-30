# frozen_string_literal: true

FactoryBot.define do
  factory :relay do
    association :territory
    association :user
  end
end
