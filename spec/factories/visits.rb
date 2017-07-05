# frozen_string_literal: true

FactoryGirl.define do
  factory :visit do
    association :advisor, factory: :user
    association :facility
    happened_at 3.days.from_now

    trait :with_visitee do
      association :visitee, factory: :contact_with_email
    end
  end
end
