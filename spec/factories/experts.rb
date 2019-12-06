# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    association :antenne

    users { [create(:user)] }
  end
end
