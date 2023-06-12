FactoryBot.define do
  factory :institution_subject do
    description { Faker::Lorem.sentence(word_count: 5) }
    institution
    subject
  end
end
