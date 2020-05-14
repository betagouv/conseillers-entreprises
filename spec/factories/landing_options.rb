FactoryBot.define do
  factory :landing_option do
    slug { Faker::Lorem.unique.word.downcase }
    form_title { Faker::Lorem.words }
    form_description { Faker::Lorem.sentence }
    association :landing
  end
end
