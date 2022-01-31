module AnnuaireHelper
  def build_count_experts_cell(experts, antenne, institution_subject)
    experts_count = experts.count
    anomalie_less, anomalie_more_specific, anomalie_more = detect_anomalies(experts_count, institution_subject, antenne, experts)
    alert_classe = alert_class(anomalie_less, anomalie_more, anomalie_more_specific)
    title, icon = set_title_and_icon(experts_count, anomalie_less, anomalie_more_specific, anomalie_more)

    tag.th(class: "right aligned #{alert_classe}", title: title) do
      tag.span { experts_count.to_s } + icon.presence
    end
  end

  private

  def alert_class(anomalie_less, anomalie_more, anomalie_more_specific)
    ('red' if anomalie_less) || ('orange' if anomalie_more_specific || anomalie_more)
  end

  def detect_anomalies(experts_count, institution_subject, antenne, experts)
    experts_communes = experts.filter_map(&:communes).compact.flatten
    # No experts on the subject
    anomalie_less = experts_count == 0 && !institution_subject.optional
    # Many Experts on the subject with specific zone but without full antenne coverage
    anomalie_more_specific = (antenne && experts_count > 1) && experts_communes.present? && !(antenne.communes - experts_communes).empty?
    # Many Experts on the subject without specific zone
    anomalie_more = (antenne && experts_count > 1) && experts_communes.empty?

    [anomalie_less, anomalie_more_specific, anomalie_more]
  end

  def set_title_and_icon(experts_count, anomalie_less, anomalie_more_specific, anomalie_more)
    if anomalie_less
      title = t('helpers.annuaire.anomalie_less')
      icon = tag.span(class: 'red ri-error-warning-line fr-ml-1v')
    elsif anomalie_more_specific
      title = t('helpers.annuaire.anomalie_more_specific', count: experts_count)
      icon = tag.span(class: 'orange ri-map-2-line fr-ml-1v')
    elsif anomalie_more
      title = t('helpers.annuaire.experts_on_subject', count: experts_count)
      icon = tag.span(class: 'orange ri-error-warning-line fr-ml-1v')
    else
      title = t('helpers.annuaire.experts_on_subject', count: experts_count)
      icon = ''
    end
    [title, icon]
  end
end
