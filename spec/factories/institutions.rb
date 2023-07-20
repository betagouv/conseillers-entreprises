# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    sequence(:name) { |n| Faker::Company.name + n.to_s }

    factory :opco do
      categories { [Category.where(label: 'opco').first_or_create] }
    end

    trait :expert_provider do
      categories { [Category.where(label: 'expert_provider').first_or_create] }
    end
  end
end
