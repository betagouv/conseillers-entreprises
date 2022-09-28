# frozen_string_literal: true

FactoryBot.define do
  factory :badge do
    color { Faker::Color.hex_color }
    title { Faker::Verb.base }
    category { :solicitations }
  end
end
