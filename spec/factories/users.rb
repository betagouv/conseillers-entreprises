# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    job { Faker::Job.title }
    password { 'yX*4Ubo_xPW!u' }
    password_confirmation { 'yX*4Ubo_xPW!u' }
    association :antenne

    trait :invitation_accepted do
      invitation_accepted_at { Time.zone.now }
    end

    trait :admin do
      after(:create) do |user, _|
        user.user_rights.create(category: 'admin')
      end
    end

    trait :manager do
      after(:create) do |user, _|
        user.managed_antennes.push(user.antenne)
      end
    end
  end
end
