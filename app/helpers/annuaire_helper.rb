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
    html = link_to(user.full_name, admin_user_path(user), title: t('annuaire_helper.build_user_name_cell.user', user_name: user.full_name, antenne: antenne))
    html << tag.span(class: 'ri-mail-add-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.not_invited')) if user.invitation_sent_at.nil?
    html << tag.span(class: 'ri-nurse-fill blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.antenne_manager')) if user.is_manager?
    html << tag.span(class: 'ri-map-2-line blue fr-ml-1v', aria: { hidden: true }, title: t('annuaire_helper.build_user_name_cell.specific_territories')) if user.experts.any? && user.experts.first.communes.any?
    html
  end

  def referencement_coverage_cell_title(referencement_coverage)
    anomalie_title = t(referencement_coverage[:anomalie], scope: 'activerecord.attributes.referencement_coverage/anomalie')
    details = t('application.modal.see_details')
    [anomalie_title, details].join(' - ')
  end

  def referencement_coverage_anomalie(anomalie_type, value)
    case anomalie_type
    when 'experts'
      experts = Expert.where(id: value)
      experts.map do |e|
        link_to(e.full_name, edit_admin_expert_path(e), title: t('annuaire_helper.build_user_name_cell.expert', expert_name: e.full_name, antenne: e.antenne))
      end.join(", ").html_safe
    else
      value
    end
  end

  def total_users(experts)
    # Permet de compter le nombre de users même non persistés pour afficher les experts sans user
    experts.each_value.sum{ |users| [users.size, 1].max }
  end

  def build_coverage_details(anomalie_details)
    content_tag(:ul) do
      anomalie_details.map do |anomalie_type, value|
        content_tag(:li) do
          content = []
          content << content_tag(:span, "#{t(anomalie_type, scope: 'activerecord.attributes.referencement_coverage/anomalie_details')} :", class: 'bold')
          territories = referencement_coverage_anomalie(anomalie_type, value)
          content << display_territories(territories, anomalie_type)
          content << display_experts(value) if anomalie_type == :experts
          content.join.html_safe
        end
      end.join.html_safe
    end
  end

  def display_experts(value)
    content_tag(:ul) do
      value.map do |expert_id|
        expert = Expert.find(expert_id)
        content_tag(:li, link_to(expert.full_name, admin_expert_path(expert), 'data-turbo': false))
      end.join.html_safe
    end
  end

  def display_territories(territories, anomalie_type)
    content = []
    if territories.present? && (anomalie_type == :extra_insee_codes || anomalie_type == :missing_insee_codes)
      content << content_tag(:ul) do
        territories.map do |territory|
          next if territory[:territories].blank?
          display_territory(territory)
        end.compact.join.html_safe
      end
    end
    content
  end

  def display_territory(territory)
    content_tag(:li) do
      content = []
      content << "#{territory[:zone_type].capitalize} :"
      content << content_tag(:ul) do
        territory[:territories].map do |sub_territory|
          content_tag(:li, "#{sub_territory[:name]} (#{sub_territory[:code]})")
        end.join.html_safe
      end
      content.join.html_safe
    end
  end
end
