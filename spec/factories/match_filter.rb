# frozen_string_literal: true

FactoryBot.define do
  factory :match_filter

  trait :for_antenne do
    antenne
  end

  trait :for_institution do
    institution
  end
end
