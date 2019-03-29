# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    label { Faker::Lorem.characters.capitalize }
  end
end
