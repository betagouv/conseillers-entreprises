# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    password { 'password' }
    password_confirmation { 'password' }

    trait :invitation_accepted do
      invitation_accepted_at { Time.zone.now }
    end
  end
end
