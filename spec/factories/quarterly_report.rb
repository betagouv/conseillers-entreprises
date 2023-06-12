FactoryBot.define do
  factory :quarterly_report do
    start_date { "2022-02-23" }
    end_date { "2022-02-23" }
    antenne

    trait :category_matches do
      category { :matches }
    end
    trait :category_stats do
      category { :stats }
    end
  end
end
