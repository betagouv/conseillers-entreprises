# frozen_string_literal: true

FactoryGirl.define do
  factory :expert do
    last_name { Faker::Name.last_name }
    role { Faker::Job.title }
    association :institution

    trait :with_first_name do
      first_name { Faker::Name.first_name }
    end

    trait :with_email do
      email { Faker::Internet.email }
    end

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end
  end
end
