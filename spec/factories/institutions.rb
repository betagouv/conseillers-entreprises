# frozen_string_literal: true

FactoryBot.define do
  factory :institution do
    name { Faker::Company.unique.name }

    factory :opco do
      categories { [build(:category, title: 'opco')] }
    end
  end
end
