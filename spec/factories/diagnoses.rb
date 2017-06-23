# frozen_string_literal: true

FactoryGirl.define do
  factory :diagnosis do
    association :visit
    content 'MyText'
  end
end
