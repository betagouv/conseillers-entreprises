# frozen_string_literal: true

ActiveAdmin.register SelectedAssistanceExpert do
  menu parent: :diagnoses, priority: 2
  actions :index, :show
  includes diagnosed_need: [diagnosis: [visit: :advisor]]

  index do
    selectable_column
    id_column
    column('Date de contact', :created_at)
    column :diagnosed_need
    column('Conseiller') { |sae| sae.diagnosed_need.diagnosis&.visit&.advisor&.full_name }
    column :expert_full_name
    column :expert_institution_name
    column :assistance_title
    column :expert_viewed_page_at
    column(:status) { |sae| t("activerecord.attributes.selected_assistance_expert.statuses.#{sae.status}") }
    actions
  end
end
