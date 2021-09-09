# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    label { Faker::Lorem.sentence(word_count: 4) }
    sequence(:slug) { |n| Faker::Lorem.word + n.to_s }
    association :theme
  end

  trait :default do
    label { "Autre besoin non référencé" }
  end
end
