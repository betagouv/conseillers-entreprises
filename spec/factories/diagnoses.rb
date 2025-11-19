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
      after(:build) do |diagnosis, _|
        diagnosis.step = 5
        diagnosis.needs = build_list(:need_with_matches, 1, diagnosis: diagnosis)
        diagnosis.completed_at = diagnosis.needs.first.matches.first.created_at
      end
    end

    after(:build) do |diagnosis, _|
      if diagnosis.matches.present?
        diagnosis.step = :completed
        diagnosis.matches.each{ |m| m.sent_at = Time.zone.now }
      end
    end
  end
end
