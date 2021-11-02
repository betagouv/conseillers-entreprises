# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    label { Faker::Verb.base }
  end
end
