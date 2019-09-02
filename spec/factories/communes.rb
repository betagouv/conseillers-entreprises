FactoryBot.define do
  factory :commune do
    insee_code { Faker::Number.number(digits: 5) }
  end
end
