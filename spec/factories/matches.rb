FactoryBot.define do
  factory :match do
    need
    expert factory: %i[expert_with_users]
    subject
    sent_at { Time.now }

    after(:build) do |match, _|
      if match.sent_at.present?
        match.need&.diagnosis&.step = :completed
        match.need&.diagnosis&.completed_at = Time.zone.now
      end
    end
  end
end
