FactoryBot.define do
  factory :need do
    diagnosis
    subject

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end

    factory :need_with_matches do
      after(:build) do |need, _|
        need.matches = build_list(:match, 1, need: need)
      end
    end

    factory :need_with_unsent_matches do
      after(:build) do |need, _|
        need.matches = build_list(:match, 1, need: need, sent_at: nil)
      end
    end

    after(:build) do |need, _|
      if need.matches.present?
        need.diagnosis.step = :completed
      end
    end
  end
end
