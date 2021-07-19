FactoryBot.define do
  factory :landing_topic do
    association :landing
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
  end
end
