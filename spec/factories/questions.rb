# frozen_string_literal: true

FactoryGirl.define do
  factory :question do
    label { Faker::Lorem.sentence }
  end
end
