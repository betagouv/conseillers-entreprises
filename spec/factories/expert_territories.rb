# frozen_string_literal: true

FactoryGirl.define do
  factory :expert_territory do
    association :expert
    association :territory
  end
end
