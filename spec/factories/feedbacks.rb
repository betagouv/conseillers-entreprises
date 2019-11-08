FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    association :need

    trait :of_expert do
      association :expert
    end

    trait :of_user do
      association :user
    end
  end
end
