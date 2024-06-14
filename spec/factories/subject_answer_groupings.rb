FactoryBot.define do
  factory :subject_answer_grouping do
    institution
    before(:create) do |sag, _|
      sag.subject_answers = create_list(:subject_answer_filter, 1, subject_answer_grouping: sag)
    end
  end
end
