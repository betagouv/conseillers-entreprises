FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    association :match
  end
end
