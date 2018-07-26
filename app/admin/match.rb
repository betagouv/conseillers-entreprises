# frozen_string_literal: true

ActiveAdmin.register Match do
  menu parent: :diagnoses, priority: 2
  actions :index, :show, :edit, :update
  permit_params :diagnosed_need_id, :assistances_experts_id, :relay_id, :status
  includes diagnosed_need: [diagnosis: [visit: :advisor]]

  index do
    selectable_column
    id_column
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
      link_to(need.id, admin_diagnosed_need_path(need)) + " (#{need.question_label})".html_safe
    end
    column :expert_full_name do |match|
      expert = match.expert
      if expert.present?
        link_to(match.expert_description, admin_expert_path(expert))
      elsif match.relay.present?
        link_to(match.expert_description, admin_relay_path(match.relay))
      else
        I18n.t('active_admin.matches.deleted', expert: match.expert_description)
      end
    end
    column :status do |match|
      I18n.t("activerecord.attributes.match.statuses.#{match.status}")
    end
    column('Page Référent') do |match|
      diagnosis_id = match.diagnosed_need.diagnosis_id
      if match.assistance_expert
        access_token = match.assistance_expert.expert.access_token
        link_to 'Page Référent', besoin_path(diagnosis_id, access_token: access_token)
      elsif match.relay
        user = match.relay.user
        link_to t('active_admin.user.impersonate', name: user.full_name), impersonate_engine.impersonate_user_path(user)
      end
    end

    actions
  end

  form do |f|
    f.inputs do
      f.input :status
    end

    f.actions
  end

  filter :territories_name, as: :string, label: I18n.t('activerecord.models.territory.other')
  filter :diagnosed_need_id, as: :string, label: I18n.t('activerecord.attributes.match.diagnosed_need')
  filter :expert_full_name
  filter :expert_institution_name
  filter :assistance_title
  filter :status
end
