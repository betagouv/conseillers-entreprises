# frozen_string_literal: true

FactoryGirl.define do
  factory :assistance do
    title { Faker::Lorem.sentence }
    association :question
    association :institution, :with_email

    trait :with_expert do
      after(:create) do |assistance|
        FactoryGirl.create :assistance_expert, assistance: assistance
      end
    end
  end
end
