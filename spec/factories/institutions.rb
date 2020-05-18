# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    name { Faker::Company.unique.name }
  end
end
