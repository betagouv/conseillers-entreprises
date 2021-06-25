# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    password { 'password' }
    password_confirmation { 'password' }
    association :antenne
    can_view_diagnoses_tab { true }

    trait :invitation_accepted do
      invitation_accepted_at { Time.zone.now }
    end
  end
end
