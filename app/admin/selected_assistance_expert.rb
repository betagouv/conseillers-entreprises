# frozen_string_literal: true

ActiveAdmin.register SelectedAssistanceExpert do
  menu parent: :diagnoses, priority: 2
  actions :index, :show
  includes :diagnosed_need

  index do
    selectable_column
    id_column
    column :diagnosed_need
    column :created_at
    column :updated_at
    column :expert_full_name
    column :expert_institution_name
    column :assistance_title
    column :expert_viewed_page_at
    column :status
    actions
  end
end
