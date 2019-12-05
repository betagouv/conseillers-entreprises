FactoryBot.define do
  factory :commune do
    insee_code { Faker::Number.unique.number(digits: 5) }
  end
end
