FactoryBot.define do
  factory :landing_subject do
    association :landing_theme
    association :subject
    slug { Faker::Lorem.unique.word.downcase }
    title { Faker::Lorem.words }
    form_title { Faker::Lorem.words }
    description { Faker::Lorem.sentence }
    form_description { Faker::Lorem.sentence }
  end
end
