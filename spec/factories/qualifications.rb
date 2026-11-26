FactoryBot.define do
  factory :qualification do
    solicitation
    qualified { true }

    trait :stop do
      qualified { false }
      details { 'Besoin imprécis' }
    end
  end
end
