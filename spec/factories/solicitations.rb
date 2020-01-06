# frozen_string_literal: true

FactoryBot.define do
  factory :solicitation do
    email { Faker::Internet.email }
    description { Faker::Lorem.sentence }
  end
end
