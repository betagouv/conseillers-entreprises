# frozen_string_literal: true

FactoryBot.define do
  factory :expert_skill do
    association :skill
    association :expert
  end
end
