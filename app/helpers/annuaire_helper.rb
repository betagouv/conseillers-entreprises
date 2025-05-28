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

  def build_coverage_button(institution_subject, coverage)
    alert_classe = defines_alert_classe(coverage)
    content_tag(:button, class: "coverage-modal-button #{alert_classe}", 'aria-controls': "modal-coverage-#{institution_subject.id}", 'data-fr-opened': 'false', title: referencement_coverage_cell_title(coverage)) do
      t(coverage[:coverage], scope: 'activerecord.attributes.referencement_coverage/coverage.short', default: "?")
    end
  end

  def total_users(experts)
    # Permet de compter le nombre de users même non persistés pour afficher les experts sans user
    experts.each_value.sum{ |users| [users.size, 1].max }
  end

  def build_coverage_details(anomalie_details)
    anomalie_details.map do |anomalie_type, value|
      next if anomalie_type == :match_filters && anomalie_details[:match_filters].values.flatten.blank?
      content = []
      content << content_tag(:div) do
        inner_content = []
        inner_content << content_tag(:h3, "#{t(anomalie_type, scope: 'activerecord.attributes.referencement_coverage/anomalie_details')}", class: 'fr-text--lead fr-m-0 fr-pt-1w')
        territories = referencement_coverage_anomalie(anomalie_type, value)
        inner_content << display_territories(territories, anomalie_type)
        inner_content << display_experts(value) if anomalie_type == :experts
        inner_content << display_match_filters(anomalie_details[:match_filters]) if anomalie_type == :match_filters && anomalie_details[:match_filters].values.flatten.any?
        inner_content.join.html_safe
      end
      content
    end.flatten.join.html_safe
  end

  def display_experts(value)
    content_tag(:ul) do
      value.map do |expert_id|
        expert = Expert.find(expert_id)
        content_tag(:li, link_to(expert.full_name, admin_expert_path(expert), 'data-turbo': false))
      end.join.html_safe
    end
  end

  private

  def display_territories(territories, anomalie_type)
    if territories.present? && (anomalie_type == :extra_insee_codes || anomalie_type == :missing_insee_codes)
      territories.map do |territory|
        next if territory[:territories].blank?
        display_territory(territory)
      end.compact.join
    end
  end

  def display_territory(territory)
    content = []
    content << content_tag(:h4, territory[:zone_type].capitalize, class: 'fr-text--md fr-m-0 fr-pt-1w')
    content << content_tag(:ul) do
      territory[:territories].map do |sub_territory|
        content_tag(:li, "#{sub_territory[:name]} (#{sub_territory[:code]})")
      end.join.html_safe
    end
    content
  end

  def defines_alert_classe(coverage)
    if coverage[:anomalie] == :no_anomalie
      'success-table-cell'
    elsif coverage[:anomalie] == :extra_insee_codes && coverage[:anomalie_details][:match_filters].values.flatten.any?
      'warning-table-cell'
    else
      'error-table-cell'
    end
  end

  def display_match_filters(match_filters)
    content = []
    content << match_filters.map do |filtrable_element_type, filters|
        next if filters.blank?

        inner_content = []
        inner_content << content_tag(:h4, I18n.t(filtrable_element_type, scope: 'activerecord.attributes.referencement_coverage/match_filters_types'), class: "fr-text--md fr-mb-0 fr-mt-1w")
        inner_content << content_tag(:ul) do
          filters.map do |filter|
            content_tag(:li, filter)
          end.join.html_safe
        end
        inner_content
      end
    content
  end
end
