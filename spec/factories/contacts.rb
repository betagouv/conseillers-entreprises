# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    company

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end
  end
end
