FactoryBot.define do
  factory :antenne do
    name { Faker::Company.name }
    association :institution
  end
end
