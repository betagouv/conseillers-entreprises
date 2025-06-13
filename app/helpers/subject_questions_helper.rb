module SubjectQuestionsHelper
  def question_label(key, format = :long)
    I18n.t(format, scope: [:activerecord, :attributes, :subject_questions, key, :label])
  end

  def answer_label(answer, filter_value: true)
    answer_filter_value = answer.filter_value || filter_value
    I18n.t(answer_filter_value, scope: [:activerecord, :attributes, :subject_questions, answer.key, :answers],
                    default: I18n.t(answer_filter_value, scope: [:boolean, :text]))
  end

  def specific_answers_file
    @specific_answers_file ||= YAML.load_file("#{Rails.root.join("config", "data", "subject_answers.yml")}")
  end
end
