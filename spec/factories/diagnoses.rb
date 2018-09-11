# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosis do
    association :visit
    content { Faker::Lorem.sentence }
    step { 1 }
  end
end
