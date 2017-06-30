# frozen_string_literal: true

FactoryGirl.define do
  factory :assistance_expert do
    association :assistance
    association :expert
  end
end
