# frozen_string_literal: true

FactoryGirl.define do
  factory :facility do
    association :company
    siret '44622002200227'
    postal_code '59392'
  end
end
