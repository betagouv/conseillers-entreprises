# frozen_string_literal: true

FactoryBot.define do
  factory :need do
    association :diagnosis
    association :subject
  end
end
