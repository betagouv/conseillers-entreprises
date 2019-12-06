FactoryBot.define do
  factory :antenne do
    name { Faker::Company.unique.name }
    association :institution
  end
end
