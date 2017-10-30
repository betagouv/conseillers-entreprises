# frozen_string_literal: true

FactoryBot.define do
  factory :assistance_expert do
    association :assistance
    association :expert
  end
end
