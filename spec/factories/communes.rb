FactoryBot.define do
  factory :commune do
    insee_code { Faker::Number.number(5) }
  end
end
