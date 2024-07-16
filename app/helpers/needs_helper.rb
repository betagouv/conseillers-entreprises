module NeedsHelper
  def need_general_context(need)
    context = ""
    if need.diagnosis.content.present? || need.solicitation&.description.present?
      context << simple_format(need.diagnosis.content.presence || need.solicitation&.description, class: 'content')
    end
    if need.content.present?
      context << simple_format(need.content, class: 'content')
    end
    raw context
  end

  def question_label(key, format = :long)
    I18n.t(format, scope: [:activerecord, :attributes, :subject_questions, key, :label])
  end
end
