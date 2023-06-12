FactoryBot.define do
  factory :institution_filter do
    additional_subject_question
    filter_value { Faker::Boolean.boolean }

    trait :for_institution do
      institution_filterable factory: %i[institution]
    end

    trait :for_solicitation do
      institution_filterable factory: %i[solicitation]
    end
  end
end
