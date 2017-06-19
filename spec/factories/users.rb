# frozen_string_literal: true

FactoryGirl.define do
  institutions = %w[Direccte MDE CCI]

  factory :user do
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone_number { Faker::PhoneNumber.phone_number }
    role { Faker::Job.title }
    institution { institutions.sample }
    password 'password'
    password_confirmation 'password'
    confirmed_at Date.today
    is_approved true
  end
end
