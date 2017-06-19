# frozen_string_literal: true

FactoryGirl.define do
  factory :mailto_log do
    association :question
    association :visit

    trait :with_assistance do
      association :assistance
    end
  end
end
