# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name,
                :city_codes,
                territory_cities: %i[id city_code _create _update _destroy]


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

    panel I18n.t('active_admin.territories.relais') do
      table_for territory.users do
        column :full_name, (proc { |user| link_to(user.full_name, admin_user_path(user)) })
        column :role
        column :institution
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
      table_for SelectedAssistanceExpert.in_territory(territory)
                    .includes(diagnosed_need: [diagnosis: [visit: [facility: :company]]])
                    .includes(:expert)
                    .order(created_at: :desc) do
        column(:id) do |selected_expert|
          link_to(selected_expert.id, admin_selected_assistance_expert_path(selected_expert))
        end
        column :created_at
        column(I18n.t('activerecord.attributes.visit.facility')) do |selected_expert|
          selected_expert.diagnosed_need&.diagnosis&.visit&.facility
        end
        column(:diagnosed_need) do |selected_expert|
          need = selected_expert.diagnosed_need
          link_to(need.question_label, admin_diagnosed_need_path(need))
        end
        column :expert_full_name do |selected_expert|
          expert = selected_expert.expert
          if expert.present?
            link_to(selected_expert.expert_description, admin_expert_path(expert))
          else
            I18n.t('active_admin.matches.deleted', expert: selected_expert.expert_description)
          end
        end
        column :status do |selected_expert|
          I18n.t("activerecord.attributes.selected_assistance_expert.statuses.#{selected_expert.status}")
        end
      end
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
