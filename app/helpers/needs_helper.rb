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

  def accordion_should_open?(omnisearch_in_accordion)
    if omnisearch_in_accordion
      needs_search_params.slice(:created_since, :created_until, :omnisearch).values.any?(&:present?)
    else
      needs_search_params[:created_since].present? || needs_search_params[:created_until].present?
    end
  end

end
