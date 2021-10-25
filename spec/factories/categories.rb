# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    title { Faker::Verb.base }
  end
end
