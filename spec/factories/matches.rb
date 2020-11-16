# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need
    association :expert
    association :subject

    after(:create) do |match, _|
      match.diagnosis.update(step: :completed)
      Need.find_each(&:update_status)
    end
  end
end
