# frozen_string_literal: true

FactoryBot.define do
  factory :expert_territory do
    association :expert
    association :territory
  end
end
