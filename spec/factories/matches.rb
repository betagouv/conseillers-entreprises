# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    association :need
    association :expert, factory: :expert_with_users
    association :subject

    after(:create) do |match, _|
      match.diagnosis.update(step: :completed, completed_at: Time.zone.now)
      match.need.reload
      Need.find_each do |n|
        n.update_status
      end
    end
  end
end
