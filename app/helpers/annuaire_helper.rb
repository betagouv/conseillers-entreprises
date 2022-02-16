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

  def build_user_name_cell(user, antenne)
    html = link_to(user.full_name, edit_admin_expert_path(user.relevant_expert), title: t('annuaire_helper.build_user_name_cell.edit_expert', expert_name: user.relevant_expert.full_name, antenne: antenne))
    html << tag.span(class: 'ri-mail-add-fill blue fr-ml-1v') if user.invitation_sent_at.nil?
    html << tag.span(class: 'ri-nurse-fill blue fr-ml-1v') if user.role_antenne_manager?
    html << tag.span(class: 'ri-map-2-line blue fr-ml-1v') if user.relevant_expert.communes.any?
    html
  end

  private

  def alert_class(anomalie_less, anomalie_more, anomalie_more_specific)
    ('red' if anomalie_less) || ('orange' if anomalie_more_specific || anomalie_more)
  end

  def detect_anomalies(experts_count, institution_subject, antenne, experts)
    experts_communes = experts.filter_map(&:communes).compact.flatten
    # No experts on the subject
    anomalie_less = experts_count == 0 && !institution_subject.optional
    # Experts with specific zone on the subject but no coverage of the whole antenna
    anomalie_more_specific = (antenne && experts_count > 1) &&
      experts_communes.present? &&
      !(antenne.communes - experts_communes).empty? &&
      experts.filter_map(&:communes).exclude?([])
    # Many Experts on the subject
    anomalie_more = (antenne && experts_count > 1) &&
      (experts_communes.size > antenne.communes.size || experts.filter_map(&:communes).include?([]))

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
