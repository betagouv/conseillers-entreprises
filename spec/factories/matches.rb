# frozen_string_literal: true

FactoryBot.define do
  factory :match do
    need
    expert factory: %i[expert_with_users]
    subject
    sent_at { Time.now }

    after(:create) do |match, _|
      match.diagnosis.update(step: :completed, completed_at: Time.zone.now)
      match.need.reload
      Need.find_each { |n| n.update_status }
    end
  end
end
