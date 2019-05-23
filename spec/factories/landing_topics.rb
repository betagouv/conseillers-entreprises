FactoryBot.define do
  factory :landing_topics do
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
  end
end
