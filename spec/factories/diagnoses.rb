# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosis do
    association :advisor, factory: :user
    association :facility
    content { Faker::Lorem.sentence }
    step { 1 }
    happened_on { 3.days.from_now }

    factory :diagnosis_completed do
      step { 5 }
      before(:create) do |diagnosis, _|
        diagnosis.needs = create_list(:need_with_matches, 1, diagnosis: diagnosis)
      end
    end

    trait :archived do
      archived_at { Time.now }
    end
  end
end
