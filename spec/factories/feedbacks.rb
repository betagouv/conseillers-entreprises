FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    association :user

    trait :for_need do
      association :feedbackable, factory: :need
    end
  end
end
