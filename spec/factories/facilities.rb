# frozen_string_literal: true

FactoryBot.define do
  factory :facility do
    company
    siret { rand(10_000_000_000_000..99_999_999_999_999).to_s }
    readable_locality { '59600 MAUBEUGE' }
    commune
  end
end
