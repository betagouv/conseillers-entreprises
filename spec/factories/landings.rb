FactoryBot.define do
  factory :landing do
    slug { 'landing-slug' }
    trait :with_options do
      landing_options { build_list :landing_option, 2 }
    end
  end
end
