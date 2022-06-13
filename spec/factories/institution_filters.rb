FactoryBot.define do
  factory :institution_filter do
    association :additional_subject_question
    filter_value { Faker::Boolean.boolean }

    trait :for_institution do
      association :institution_filterable, factory: :institution
    end

    trait :for_solicitation do
      association :institution_filterable, factory: :solicitation
    end
  end
end
