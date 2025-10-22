FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    job { Faker::Job.title }
    password { 'aaQQwwXXssZZ22##' }
    password_confirmation { 'aaQQwwXXssZZ22##' }
    antenne

    trait :with_expert do
      after(:build) do |user, _|
        user.experts << build(:expert, antenne: user.antenne)
      end
    end

    trait :with_expert_subjects do
      after(:build) do |user, _|
        user.experts << build(:expert, :with_expert_subjects, antenne: user.antenne)
      end
    end

    trait :invitation_accepted do
      invitation_accepted_at { Time.zone.now }
    end

    trait :admin do
      after(:build) do |user, _|
        user.user_rights.build(category: 'admin')
      end
    end

    trait :manager do
      antenne factory: [:antenne, :with_experts_subjects]
      after(:build) do |user, _|
        user.managed_antennes.push(user.antenne)
      end

      after :create do |user, _|
        user.user_rights.reload
      end
    end

    trait :cooperation_manager do
      managed_cooperations { [build(:cooperation, institution: institution)] }
    end

    trait :national_manager do
      antenne factory: [:antenne, :with_experts_subjects, :national]
      after(:build) do |user, _|
        user.managed_antennes.push(user.antenne)
      end
    end

    trait :national_referent do
      antenne factory: [:antenne, :with_experts_subjects]
      after(:build) do |user, _|
        user.user_rights.build(category: 'admin')
        user.user_rights.build(category: 'national_referent')
      end
    end

    trait :territorial_referent do
      antenne factory: [:antenne, :with_experts_subjects]
      after(:build) do |user, _|
        user.user_rights.build(category: 'admin')
        territorial_zone = build(:territorial_zone, :region, code: '52')
        user.user_rights.build(category: 'territorial_referent', territorial_zone: territorial_zone)
      end
    end

    trait :main_referent do
      antenne factory: [:antenne, :with_experts_subjects]
      after(:build) do |user, _|
        user.user_rights.build(category: 'admin')
        user.user_rights.build(category: 'main_referent')
      end
    end
  end
end
