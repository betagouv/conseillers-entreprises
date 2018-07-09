# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    role { Faker::Job.title }
    association :institution

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end
  end
end
