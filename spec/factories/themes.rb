FactoryBot.define do
  factory :theme do
    label { Faker::Lorem.sentence(word_count: 5) }
  end
end
