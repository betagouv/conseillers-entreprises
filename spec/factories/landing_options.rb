FactoryBot.define do
  factory :landing_option do
    sequence(:slug) { |n| Faker::Lorem.word + n.to_s }
    form_title { Faker::Lorem.words }
    form_description { Faker::Lorem.sentence }
    association :landing
  end
end
