FactoryBot.define do
  factory :activity_report do
    start_date { "2022-02-23" }
    end_date { "2022-02-23" }

    trait :category_matches do
      category { :matches }
      reportable factory: %i[antenne]
    end
    trait :category_stats do
      category { :stats }
      reportable factory: %i[antenne]
    end
    trait :category_cooperation do
      category { :cooperation }
      reportable factory: %i[cooperation]
    end
    trait :category_solicitations do
      category { :solicitations }
      reportable factory: %i[cooperation]
    end
  end
end
