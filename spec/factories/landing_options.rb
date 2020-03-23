FactoryBot.define do
  factory :landing_option do
    slug { Faker::Lorem.word }
    description { Faker::Lorem.paragraph }
  end
end
