# frozen_string_literal: true

FactoryGirl.define do
  factory :visit do
    association :advisor, factory: :user
    happened_at '2017-06-08'
    siret '123456789'
  end
end
