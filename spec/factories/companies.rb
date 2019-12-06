# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.unique.name }
    siren { rand(100_000_000..999_999_999).to_s }
  end
end
