# frozen_string_literal: true

FactoryGirl.define do
  factory :territory do
    name { Faker::Pokemon.location }
  end
end
