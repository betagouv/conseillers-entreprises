# frozen_string_literal: true

FactoryGirl.define do
  factory :assistance do
    association :answer
    description 'MyText'
  end
end
