FactoryBot.define do
  factory :landing_subject do
    association :landing_theme
    association :subject
    sequence(:slug) { |n| "ls" + Faker::Lorem.word + n.to_s }
    title { Faker::Lorem.words }
    form_title { Faker::Lorem.words }
    description { Faker::Lorem.sentence }
    form_description { Faker::Lorem.sentence }
  end
end
