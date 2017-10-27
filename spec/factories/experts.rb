# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    role { Faker::Job.title }
    association :institution

    trait :with_first_name do
      first_name { Faker::Name.first_name }
    end

    trait :with_phone_number do
      phone_number { Faker::PhoneNumber.phone_number }
    end
  end
end
