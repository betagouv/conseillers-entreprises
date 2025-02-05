# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    phone_number { Faker::PhoneNumber.phone_number }
    job { Faker::Job.title }
    password { 'yX*4Ubo_xPW!u' }
    password_confirmation { 'yX*4Ubo_xPW!u' }
    antenne

    trait :with_expert do
      after(:create) do |user, _|
        user.experts << create(:expert, antenne: user.antenne)
      end
    end

    trait :with_expert_subjects do
      after(:create) do |user, _|
        user.experts << create(:expert, :with_expert_subjects, antenne: user.antenne)
      end
    end

    trait :invitation_accepted do
      invitation_accepted_at { Time.zone.now }
    end

    trait :admin do
      after(:create) do |user, _|
        user.user_rights.create(category: 'admin')
      end
    end

    trait :manager do
      antenne factory: [:antenne, :with_experts_subjects], strategy: :create
      after(:create) do |user, _|
        user.managed_antennes.push(user.antenne)
      end
    end

    trait :cooperation_manager do
      after(:create) do |user, _|
        user.managed_cooperations << create(:cooperation, institution: user.institution)
      end
    end

    trait :national_manager do
      antenne factory: [:antenne, :with_experts_subjects, :national], strategy: :create
      after(:create) do |user, _|
        user.managed_antennes.push(user.antenne)
      end
    end

    trait :national_referent do
      antenne factory: [:antenne, :with_experts_subjects], strategy: :create
      after(:create) do |user, _|
        user.user_rights.create(category: 'admin')
        user.user_rights.create(category: 'national_referent')
      end
    end

    trait :main_referent do
      antenne factory: [:antenne, :with_experts_subjects], strategy: :create
      after(:create) do |user, _|
        user.user_rights.create(category: 'admin')
        user.user_rights.create(category: 'main_referent')
      end
    end
  end
end
