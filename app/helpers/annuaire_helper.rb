module AnnuaireHelper
  def antennes_count_display(antennes_count, institution_id)
    count = antennes_count[institution_id] || 0
    label = Antenne.model_name.human(count: count).downcase
    [count, label].join(' ')
  end

  def users_count_display(users_count, institution_id)
    count = users_count[institution_id] || 0
    label = User.model_name.human(count: count).downcase
    [count, label].join(' ')
  end

  def build_user_name_cell(user, antenne)
    html = link_to(user.full_name, edit_admin_expert_path(user.relevant_expert), title: t('annuaire_helper.build_user_name_cell.edit_expert', expert_name: user.relevant_expert.full_name, antenne: antenne))
    html << tag.span(class: 'ri-mail-add-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.not_invited')) if user.invitation_sent_at.nil?
    html << tag.span(class: 'ri-nurse-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.antenne_manager')) if user.is_manager?
    html << tag.span(class: 'ri-map-2-line blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.specific_territories')) if user.relevant_expert.communes.any?
    html
  end

  def referencement_coverage_cell_title(referencement_coverage)
    anomalie_title = t(referencement_coverage.anomalie, scope: 'activerecord.attributes.referencement_coverage/anomalie')
    details = t('application.modal.see_details')
    [anomalie_title, details].join(' - ')
  end

  def referencement_coverage_anomalie(anomalie_type, value)
    case anomalie_type
    when 'experts'
      ids = value
      experts = Expert.where(id: value)
      experts.map do |e|
        link_to(e.full_name, edit_admin_expert_path(e), title: t('annuaire_helper.build_user_name_cell.edit_expert', expert_name: e.full_name, antenne: e.antenne))
      end.join(", ").html_safe
    else
      value
    end
  end
end
