FactoryBot.define do
  factory :landing_option do
    slug { Faker::Lorem.unique.word.downcase }
    title { Faker::Lorem.words }
    association :landing
  end
end
