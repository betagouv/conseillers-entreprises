# frozen_string_literal: true

FactoryBot.define do
  factory :search do
    user
    query { Faker::Lorem.word }
    label { Faker::Lorem.word.capitalize }
  end
end
