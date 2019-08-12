# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    password { 'password' }
    password_confirmation { 'password' }
    confirmed_at { Time.zone.now }
    is_approved { true }

    trait :just_registered do
      is_approved { false }
    end
  end
end
