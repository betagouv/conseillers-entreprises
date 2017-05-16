# frozen_string_literal: true

FactoryGirl.define do
  factory :answer do
    label 'MyString'
    association :question
  end
end
