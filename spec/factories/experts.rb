# frozen_string_literal: true

FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    association :antenne

    factory :expert_with_users do
      users { [build(:user, :invitation_accepted, email: email)] }
    end
  end
end
