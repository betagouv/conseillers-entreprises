FactoryBot.define do
  factory :subject_cover do
    antenne { nil }
    institution_subject { nil }
    cover { "MyString" }
    anomalie { 1 }
    anomalie_details { "" }
  end
end
