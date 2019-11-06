# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    label { Faker::Lorem.sentence }
    association :theme
  end

  trait :default do
    label { "Autre besoin non référencé" }
  end
end
