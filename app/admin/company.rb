# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 4
  permit_params :name, :siren

  filter :name
  filter :siren
  filter :legal_form_code
  filter :created_at
  filter :updated_at

  show do
    default_main_content

    panel I18n.t('activerecord.attributes.company.facilities') do
      table_for company.facilities do
        column :siret
        column :city_code
        column :naf_code
        column :readable_locality
      end
    end

    panel I18n.t('active_admin.territories.contacted_experts') do
      table_for Match.of_facilities(company.facilities)
        .includes(diagnosed_need: [diagnosis: [visit: [facility: :company]]])
        .includes(:expert)
        .order(created_at: :desc) do
        column(:id) do |match|
          link_to(match.id, admin_match_path(match))
        end
        column :created_at
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
end
