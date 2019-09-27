FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    association :need
    association :expert
  end
end
