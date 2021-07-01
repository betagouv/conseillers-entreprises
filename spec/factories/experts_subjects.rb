FactoryBot.define do
  factory :expert_subject do
    intervention_criteria { Faker::Lorem.sentence }
    association :expert, factory: :expert_with_users
    association :institution_subject
  end
end
