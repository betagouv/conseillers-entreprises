FactoryBot.define do
  factory :landing_topic do
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
  end
end
