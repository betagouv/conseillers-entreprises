module AnnuaireHelper
  def build_user_name_cell(user, antenne)
    html = link_to(user.full_name, edit_admin_expert_path(user.relevant_expert), title: t('annuaire_helper.build_user_name_cell.edit_expert', expert_name: user.relevant_expert.full_name, antenne: antenne))
    html << tag.span(class: 'ri-mail-add-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.not_invited')) if user.invitation_sent_at.nil?
    html << tag.span(class: 'ri-nurse-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.antenne_manager')) if user.is_manager?
    html << tag.span(class: 'ri-map-2-line blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.specific_territories')) if user.relevant_expert.communes.any?
    html
  end
end
