# frozen_string_literal: true

FactoryGirl.define do
  factory :institution do
    name { Faker::Company.name }
  end
end
