# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name,
    :city_codes,
    territory_cities: %i[id city_code _create _update _destroy]

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row(:city_codes) do |territory|
        safe_join(territory.territory_cities.map do |territory_city|
          link_to territory_city.city_code, admin_territory_city_path(territory_city)
        end, ', '.html_safe)
      end
    end

    panel I18n.t('active_admin.territories.experts') do
      table_for territory.experts.includes(:institution) do
        column :full_name, (proc { |expert| link_to(expert.full_name, admin_expert_path(expert)) })
        column :role
        column :institution
      end
    end

    panel I18n.t('active_admin.territories.contacted_experts') do
      table_for Match.in_territory(territory)
        .includes(diagnosed_need: [diagnosis: [visit: [facility: :company]]])
        .includes(diagnosed_need: [diagnosis: [visit: :advisor]])
        .includes(:expert)
        .order(created_at: :desc) do
        column(:id) do |match|
          link_to(match.id, admin_match_path(match))
        end
        column :created_at
        column(I18n.t('activerecord.attributes.visit.advisor')) do |match|
          advisor = match.diagnosed_need.diagnosis.visit.advisor
          link_to(advisor.full_name_with_role, admin_user_path(advisor))
        end
        column(I18n.t('activerecord.attributes.visit.facility')) do |match|
          match.diagnosed_need&.diagnosis&.visit&.facility
        end
        column(:diagnosed_need) do |match|
          need = match.diagnosed_need
          link_to(need.question_label, admin_diagnosed_need_path(need))
        end
        column :expert_full_name do |match|
          expert = match.expert
          if expert.present?
            link_to(match.expert_description, admin_expert_path(expert))
          else
            I18n.t('active_admin.matches.deleted', expert: match.expert_description)
          end
        end
        column :status do |match|
          I18n.t("activerecord.attributes.match.statuses.#{match.status}")
        end
      end
    end
  end

  sidebar I18n.t('active_admin.territories.relais'), only: :show do
    table_for territory.users do
      column { |user| link_to(user.full_name, admin_user_path(user)) + "<br/> #{user.role}, #{user.institution}".html_safe }
    end
  end

  form do |f|
    f.inputs I18n.t('activerecord.attributes.territory.name') do
      f.input :name
    end

    f.inputs I18n.t('activerecord.attributes.territory_city.city_code') do
      f.input :city_codes
    end

    f.actions
  end

  filter :experts, collection: -> { Expert.ordered_by_names }
  filter :name
  filter :created_at
  filter :updated_at
end
