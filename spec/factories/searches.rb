# frozen_string_literal: true

FactoryGirl.define do
  factory :search do
    association :user
    query { Faker::Lorem.word }
    label { Faker::Lorem.word.capitalize }
  end
end
