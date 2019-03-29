# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    label { Faker::Lorem.sentence }
    association :theme
  end
end
