# frozen_string_literal: true

FactoryBot.define do
  factory :contact do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    association :company

    trait :with_email do
      email { Faker::Internet.unique.email }
    end

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end

    factory :contact_with_email do
      with_email
    end
  end
end
