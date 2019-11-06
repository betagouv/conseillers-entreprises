FactoryBot.define do
  factory :institution_subject do
    description { Faker::Lorem.sentence }
    association :institution
    association :subject
  end
end
