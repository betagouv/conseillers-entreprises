FactoryBot.define do
  factory :company_satisfaction do
    contacted_by_expert { Faker::Boolean.boolean }
    useful_exchange { Faker::Boolean.boolean }
    comment { Faker::Lorem.paragraph }
    need
  end
end
