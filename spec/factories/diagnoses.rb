# frozen_string_literal: true

FactoryBot.define do
  factory :diagnosis do
    advisor factory: %i[user]
    facility
    solicitation
    visitee factory: %i[contact with_phone_number]
    content { Faker::Lorem.sentence }
    step { 1 }
    happened_on { 3.days.from_now }

    factory :diagnosis_completed do
      after(:create) do |diagnosis, _|
        diagnosis.step = 5
        diagnosis.needs = create_list(:need_with_matches, 1, diagnosis: diagnosis)
        diagnosis.completed_at = diagnosis.needs.first.matches.first.created_at
        diagnosis.save!
      end
    end

    after(:create) do |diagnosis, _|
      if diagnosis.matches.present?
        diagnosis.update_columns(step: :completed)
        diagnosis.matches.each{ |m| m.update_columns(sent_at: Time.zone.now) }
      end
    end
  end
end
