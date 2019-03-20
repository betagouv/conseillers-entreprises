# frozen_string_literal: true

FactoryBot.define do
  factory :territory do
    name { Faker::Address.country }
  end
end
