# frozen_string_literal: true

FactoryGirl.define do
  factory :territory_user do
    association :territory
    association :user
  end
end
