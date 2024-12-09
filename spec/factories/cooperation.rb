FactoryBot.define do
  factory :cooperation do
    institution
    sequence(:name) { |n| "Cooperation " + Faker::Lorem.word + n.to_s }
  end
end
