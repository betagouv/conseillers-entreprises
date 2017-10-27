# frozen_string_literal: true

FactoryBot.define do
  factory :visit do
    association :advisor, factory: :user
    association :facility

    trait :with_date do
      happened_on { 3.days.from_now }
    end

    trait :with_visitee do
      association :visitee, factory: :contact_with_email
    end
  end
end
