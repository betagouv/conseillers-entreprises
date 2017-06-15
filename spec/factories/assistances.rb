# frozen_string_literal: true

FactoryGirl.define do
  factory :assistance do
    title { Faker::Lorem.sentence }
    association :question
    association :company
  end
end
