# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosed_need do
    association :diagnosis
    association :question
  end
end
