# frozen_string_literal: true

FactoryGirl.define do
  factory :search do
    query { Faker::Lorem.word }
    user nil
    label { Faker::Lorem.word.capitalize }
  end
end
