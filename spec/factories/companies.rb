# frozen_string_literal: true

FactoryGirl.define do
  factory :company do
    sequence(:name) { |i| "company#{i}" }
    sequence(:siren) { rand(100_000_000..999_999_999).to_s }
  end
end
