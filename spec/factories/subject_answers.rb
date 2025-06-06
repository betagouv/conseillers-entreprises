FactoryBot.define do
  factory :subject_answer do
    subject_question
    filter_value { ["true", "false", "other"].sample }

    factory :subject_answer_filter, class: "SubjectAnswer::Filter" do
      subject_answer_grouping
    end

    factory :solicitation_subject_answer, class: "SubjectAnswer::Item" do
      subject_questionable factory: :solicitation
    end

    factory :need_subject_answer, class: "SubjectAnswer::Item" do
      subject_questionable factory: :need
    end
  end
end
