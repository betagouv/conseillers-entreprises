module SubjectQuestionsHelper
  def question_label(key, format = :long)
    I18n.t(format, scope: [:activerecord, :attributes, :subject_questions, key, :label])
  end

  def answer_label(question_key, answer_label_key)
    I18n.t(answer_label_key, scope: [:activerecord, :attributes, :subject_questions, question_key, :answers],
                    default: I18n.t(answer_label_key, scope: [:boolean, :text]))
  end

  def specific_answers_file
    @specific_answers_file ||= YAML.load_file("#{Rails.root.join("config", "data", "subject_answers.yml")}")
  end
end
