# frozen_string_literal: true

FactoryBot.define do
  factory :solicitation do
    landing
    description { Faker::Lorem.sentences(number: 3) }
    full_name { Faker::Name.unique.name }
    phone_number { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    options { { 'First option' => '1', 'Second option' => '0' } }
  end
end
