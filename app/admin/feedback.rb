ActiveAdmin.register Feedback do
  menu parent: :diagnoses, priority: 4

  ## Index
  #
  includes :expert, user: [:institution, :antenne], need: [:facility]

  index do
    selectable_column
    id_column
    column :created_at

    column :need
    column :expert
    column :user
    column :description

    actions dropdown: true
  end

  filter :description
  filter :created_at
  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :user, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }

  ## CSV
  #
  csv do
    column :id
    column :created_at
    column :need
    column :expert
    column :user
    column :description
    column(:siret) { |f| f.need.facility.siret }
    column(:institution) { |f| f.user&.institution || f.expert.institution }
    column(:antenne) { |f| f.user&.antenne || f.expert.antenne }
  end

  ## Show
  #
  show do
    attributes_table do
      row :created_at
      row :need
      row :expert
      row :user
      row :description
    end
  end

  ## Form
  #
  permit_params :description

  form do |f|
    f.input :description

    actions
  end
end
