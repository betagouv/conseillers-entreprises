FactoryBot.define do
  factory :landing do
    slug { Faker::Lorem.unique.word.downcase }
    trait :with_subjects do
      landing_themes { build_list :landing_theme, 2, :with_subjects }
    end
  end
end
