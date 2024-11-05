FactoryBot.define do
  factory :spam do
    email { Faker::Internet.email }
  end
end
