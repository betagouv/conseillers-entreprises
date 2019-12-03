# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need
    association :expert
    association :subject
  end
end
