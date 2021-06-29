FactoryBot.define do
  factory :expert_subject do
    intervention_criteria { Faker::Lorem.sentence }
    association :expert
    association :institution_subject
  end
end
