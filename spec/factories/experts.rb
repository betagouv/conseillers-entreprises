# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    association :antenne

    users { [create(:user)] }
  end
end
