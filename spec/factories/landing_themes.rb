FactoryBot.define do
  factory :landing_theme do
    sequence(:slug) { |n| "lt" + Faker::Lorem.word + n.to_s }
    title { Faker::Company.bs }
    description { Faker::Lorem.paragraph }
    trait :with_subjects do
      landing_subjects { build_list :landing_subject, 2 }
    end
    trait :with_landings do
      landings { build_list :landing, 1 }
    end
  end
end
