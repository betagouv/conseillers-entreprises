module SubjectQuestionsHelper
  def question_label(key, format = :long)
    I18n.t(format, scope: [:activerecord, :attributes, :subject_questions, key, :label])
  end

  def specific_answers_file
    @specific_answers_file ||= YAML.load_file("#{Rails.root.join("config", "data", "subject_answers.yml")}")
  end
end
