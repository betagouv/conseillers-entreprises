FactoryBot.define do
  factory :subject do
    label { Faker::Lorem.sentence(word_count: 4) }
    sequence(:slug) { |n| Faker::Lorem.word + n.to_s }
    theme

    trait :other_need do
      label { "Autre besoin non référencé" }
      theme factory: %i[theme other_need]
    end
  end
end
