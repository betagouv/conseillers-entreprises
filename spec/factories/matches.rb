# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need
    association :expert
    association :subject

    after(:create) do |match, _|
      match.diagnosis.update_columns(step: :completed)
    end
  end
end
