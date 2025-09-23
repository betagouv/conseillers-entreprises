FactoryBot.define do
  factory :expert do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    antenne

    factory :expert_with_users do
      users { [build(:user, :invitation_accepted, email: email)] }
    end

    trait :with_reminders_register do
      after(:create) do |expert, _|
        create :reminders_register, expert: expert, run_number: RemindersRegister.last_run_number.presence || 0, category: :remainder, processed: true
      end
    end

    trait :with_expert_subjects do
      after(:create) do |expert, _|
        create :expert_subject, expert: expert, institution_subject: create(:institution_subject, institution: expert.antenne.institution)
      end
    end
  end
end
