FactoryBot.define do
  factory :landing do
    slug { 'landing-slug' }
    trait :featured do
      featured_on_home { true }
      home_sort_order { 0 }
    end
  end
end
