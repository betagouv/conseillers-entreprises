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

  def partner_title(solicitation)
    return if solicitation.nil?
    if solicitation.origin_title.present? && solicitation.landing.partner_url.present?
      "#{solicitation.origin_title} (#{solicitation.landing.partner_url})"
    elsif solicitation.origin_url.present?
      solicitation.origin_url
    else
      solicitation.landing.partner_url
    end
  end

  def partner_url(solicitation)
    return if solicitation.nil?
    return solicitation.origin_url if solicitation.origin_url.present?
    solicitation.landing.partner_url
  end
end
