# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosed_need do
    association :diagnosis
    question_label { Faker::Lorem.sentence }
    question { nil }
  end
end
