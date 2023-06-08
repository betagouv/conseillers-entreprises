FactoryBot.define do
  factory :email_retention do
    waiting_time { 1 }
    first_paragraph { Faker::Lorem.words }
    first_subject_label { Faker::Lorem.words }
    second_subject_label { Faker::Lorem.words }
    email_subject { Faker::Lorem.words }
    subject
    first_subject factory: %i[subject]
    second_subject factory: %i[subject]
  end
end
