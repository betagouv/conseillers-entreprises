# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    password_confirmation 'password'
    confirmed_at Date.today
    approved true
  end
end
