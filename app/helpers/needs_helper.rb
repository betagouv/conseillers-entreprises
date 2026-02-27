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

  def selected_antenne_id(antennes_collection)
    # Return the antenne_id from session if present
    return needs_search_params[:antenne_id] if needs_search_params[:antenne_id].present?

    # select the aggregated antenne (with " avec antennes locales") if available
    aggregated_antenne = antennes_collection.find { |a| a[:id].to_s.include?(I18n.t('helpers.stats_helper.with_locales')) }
    return aggregated_antenne[:id] if aggregated_antenne

    # Fallback: select the first antenne
    antennes_collection.first&.dig(:id)
  end
end
