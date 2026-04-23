FactoryBot.define do
  factory :theme do
    label { Faker::Lorem.sentence(word_count: 5) }

    trait :other_need do
      label { "Autres typologies de besoins" }
    end
  end
end
