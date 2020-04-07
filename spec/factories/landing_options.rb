FactoryBot.define do
  factory :landing_option do
    slug { Faker::Lorem.unique.word.downcase }
    description { Faker::Lorem.paragraph }
  end
end
