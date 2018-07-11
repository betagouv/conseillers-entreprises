# frozen_string_literal: true

ActiveAdmin.register Match do
  menu parent: :diagnoses, priority: 2
  actions :index, :show, :edit, :update
  permit_params :diagnosed_need_id, :assistances_experts_id, :relay_id, :status
  includes diagnosed_need: [diagnosis: [visit: :advisor]]

  index do
    selectable_column
    id_column
    column('Date de contact', :created_at)
    column :diagnosed_need
    column('Conseiller') { |match| match.diagnosed_need.diagnosis&.visit&.advisor&.full_name }
    column :expert_full_name
    column :expert_institution_name
    column :assistance_title
    column :expert_viewed_page_at
    column(:status) { |match| t("activerecord.attributes.match.statuses.#{match.status}") }
    column('Page Référent') do |match|
      diagnosis_id = match.diagnosed_need.diagnosis_id
      if match.assistance_expert
        access_token = match.assistance_expert.expert.access_token
        link_to 'Page Référent', diagnosis_experts_path(diagnosis_id: diagnosis_id, access_token: access_token)
      else
        link_to 'Page Référent', diagnosis_relays_path(diagnosis_id: diagnosis_id, relay_id: match.relay_id)
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
