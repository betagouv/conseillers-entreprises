# frozen_string_literal: true

FactoryGirl.define do
  factory :contact do
    last_name { Faker::Name.last_name }
    role { Faker::Job.title }
    association :company

    trait :with_first_name do
      first_name { Faker::Name.first_name }
    end

    trait :with_email do
      email { Faker::Internet.email }
    end

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end

    factory :contact_with_email do
      with_email
    end
  end
end
