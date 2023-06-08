FactoryBot.define do
  factory :feedback do
    description { Faker::Lorem.paragraph }
    user

    trait :for_need do
      category { :need }
      feedbackable factory: %i[need]
    end

    trait :for_need_reminder do
      category { :need_reminder }
      feedbackable factory: %i[need]
    end

    trait :for_solicitation do
      category { :solicitation }
      feedbackable factory: %i[solicitation], status: :in_progress
    end
  end
end
