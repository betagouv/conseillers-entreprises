FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    association :user

    trait :for_need do
      category { :need }
      association :feedbackable, factory: :need
    end

    trait :for_need_reminder do
      category { :need_reminder }
      association :feedbackable, factory: :need
    end

    trait :for_solicitation do
      category { :solicitation }
      association :feedbackable, factory: :solicitation
    end
  end
end
