FactoryBot.define do
  factory :subject do
    label { Faker::Lorem.sentence(word_count: 4) }
    sequence(:slug) { |n| Faker::Lorem.word + n.to_s }
    theme
  end

  trait :default do
    label { "Autre besoin non référencé" }
  end
end
