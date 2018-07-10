# frozen_string_literal: true

ActiveAdmin.register Relay do
  menu parent: :territories, priority: 1
  permit_params :territory_id, :user_id
  includes :territory, :user

  ## Index
  #
  filter :territory_name, as: :string, label: I18n.t('activerecord.attributes.relay.territory')
  filter :user_full_name, as: :string, label: I18n.t('activerecord.attributes.relay.user')
  filter :created_at
  filter :updated_at

  ## Form
  #
  form do |f|
    inputs do
      f.input :territory, collection: Territory.ordered_by_name
      f.input :user, collection: User.ordered_by_names
    end
    actions
  end

  ## Show
  #
  show do
    default_main_content

    panel I18n.t('active_admin.territories.contacted_experts') do
      table_for Match.of_relay(relay)
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
end
