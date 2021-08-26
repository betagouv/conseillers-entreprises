FactoryBot.define do
  factory :institution_subject do
    description { Faker::Lorem.sentence(word_count: 5) }
    association :institution
    association :subject
  end
end
