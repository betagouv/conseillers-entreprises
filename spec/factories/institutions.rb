# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    sequence(:name) { |n| Faker::Company.name + n.to_s }

    factory :opco do
      categories { [build(:category, title: 'opco')] }
    end
  end
end
