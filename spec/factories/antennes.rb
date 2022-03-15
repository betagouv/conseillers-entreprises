FactoryBot.define do
  factory :antenne do
    name { Faker::Company.unique.name }
    association :institution
    territorial_level { :local }
  end

  trait :national do
    territorial_level { :national }
  end

  trait :regional do
    territorial_level { :regional }
  end

  trait :local do
    territorial_level { :local }
  end
end
