# frozen_string_literal: true

FactoryBot.define do
  factory :visit do
    association :advisor, factory: :user
    association :facility

    happened_on { 3.days.from_now }
  end
end
