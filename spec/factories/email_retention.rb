FactoryBot.define do
  factory :email_retention do
    waiting_time { 1 }
    first_paragraph { Faker::Lorem.words }
    first_subject_label { Faker::Lorem.words }
    second_subject_label { Faker::Lorem.words }
    email_subject { Faker::Lorem.words }
    association :subject
    association :first_subject, factory: :subject
    association :second_subject, factory: :subject
  end
end
