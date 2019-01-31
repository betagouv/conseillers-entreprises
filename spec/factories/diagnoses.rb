# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosis do
    association :advisor, factory: :user
    association :facility
    content { Faker::Lorem.sentence }
    step { 1 }

    happened_on { 3.days.from_now }
  end
end
