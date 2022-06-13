FactoryBot.define do
  factory :additional_subject_question do
    key { Faker::Company.catch_phrase.parameterize.underscore }
    association :subject
  end
end
