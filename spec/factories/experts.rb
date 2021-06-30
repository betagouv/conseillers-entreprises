# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    association :antenne

    factory :expert_with_users do
      users { [build(:user, email: email)] }
    end
  end
end
