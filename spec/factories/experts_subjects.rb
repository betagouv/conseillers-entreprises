FactoryBot.define do
  factory :expert_subject do
    intervention_criteria { Faker::Lorem.sentence(word_count: 5) }
    expert factory: %i[expert_with_users]
    institution_subject
  end
end
