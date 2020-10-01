FactoryBot.define do
  factory :expert_subject do
    description { Faker::Lorem.sentence }
    association :expert
    association :institution_subject
  end
end
