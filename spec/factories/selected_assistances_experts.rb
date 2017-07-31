# frozen_string_literal: true

FactoryGirl.define do
  factory :selected_assistance_expert do
    association :diagnosed_need
    association :assistance_expert
  end
end
