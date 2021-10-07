# frozen_string_literal: true

FactoryBot.define do
  factory :solicitation do
    landing
    landing_subject
    description { Faker::Lorem.sentences(number: 3) }
    full_name { Faker::Name.unique.name }
    phone_number { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    siret { Faker::Company.french_siret_number }

    trait :with_diagnosis do
      diagnosis { build :diagnosis }
    end
  end
end
