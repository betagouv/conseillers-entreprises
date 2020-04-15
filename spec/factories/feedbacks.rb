FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }

    trait :of_expert do
      association :expert
    end

    trait :of_user do
      association :user
    end

    trait :for_need do
      association :feedbackable, factory: :need
    end
  end
end
