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

    trait :with_reminders_register do
      after(:create) do |expert, _|
        create :reminders_register, expert: expert, created_at: 1.week.ago, category: :remainder
      end
    end
  end
end
