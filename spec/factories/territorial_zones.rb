FactoryBot.define do
  factory :territorial_zone do
    zoneable factory: %i[expert antenne].sample

    trait :commune do
      zone_type { 'commune' }
      code { Faker::Number.number(digits: 5) }
    end

    trait :departement do
      zone_type { 'departement' }
      code { Faker::Number.number(digits: 2) }
    end

    trait :region do
      zone_type { 'region' }
      code { Faker::Number.number(digits: 2) }
    end

    trait :epci do
      zone_type { 'epci' }
      code { Faker::Number.number(digits: 9) }
    end
  end
end
