# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need
    association :expert, factory: :expert_with_user
    association :subject

    after(:create) do |match, _|
      match.diagnosis.update(step: :completed, completed_at: Time.zone.now)
      Need.find_each(&:update_status)
    end
  end
end
