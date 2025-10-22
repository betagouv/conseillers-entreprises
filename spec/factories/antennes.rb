FactoryBot.define do
  factory :antenne do
    name { Faker::Company.unique.name }
    institution
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

  trait :with_experts_subjects do
    after(:build) do |antenne|
      antenne.experts << build(:expert_with_users, experts_subjects: build_list(:expert_subject, 1))
    end
  end

  trait :with_manager do
    after(:build) do |antenne|
      antenne.managers << build(:user)
    end
  end
end
