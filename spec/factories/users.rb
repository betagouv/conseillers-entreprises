# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    confirmed_at Date.today
    is_approved true
  end
end
