FactoryBot.define do
  factory :territorial_zone do
    zoneable factory: %i[expert antenne].sample

    trait :commune do
      zone_type { 'commune' }
      code { "02691" }
    end

    trait :departement do
      zone_type { 'departement' }
      code { "72" }
    end

    trait :region do
      zone_type { 'region' }
      code { "53" }
    end

    trait :epci do
      zone_type { 'epci' }
      code { "200054781" }
    end
  end
end
