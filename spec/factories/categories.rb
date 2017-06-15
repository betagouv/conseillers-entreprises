# frozen_string_literal: true

FactoryGirl.define do
  factory :category do
    label { Faker::Lorem.word.capitalize }
  end
end
