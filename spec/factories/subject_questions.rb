FactoryBot.define do
  factory :subject_question do
    key { Faker::Company.catch_phrase.parameterize.underscore }
    subject
  end
end
