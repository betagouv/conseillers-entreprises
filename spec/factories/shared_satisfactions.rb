FactoryBot.define do
  factory :shared_satisfaction do
    company_satisfaction
    user
    expert
    seen_at { nil }
  end
end
