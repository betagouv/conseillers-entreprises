# frozen_string_literal: true

FactoryGirl.define do
  factory :institution do
    name { Faker::Company.name }

    trait :with_email do
      email { Faker::Internet.email }
    end
  end
end
