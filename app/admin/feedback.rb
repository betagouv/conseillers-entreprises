ActiveAdmin.register Feedback do
  menu parent: :diagnoses, priority: 4

  ## Index
  #
  includes :match, :expert, :diagnosed_need

  index do
    selectable_column
    id_column

    column :match do |f|
      link_to(f.diagnosed_need, admin_match_path(f.match))
    end
    column :expert do |f|
      admin_link_to(f, :expert)
    end
    column :description

    actions dropdown: true
  end

  filter :description
  filter :created_at
  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }

  ## CSV
  #
  csv do
    column :id
    column :diagnosed_need
    column :expert
    column :description
  end

  ## Show
  #
  show do
    attributes_table do
      row :match do |f|
        link_to(f.diagnosed_need, admin_match_path(f.match))
      end
      row :expert do |f|
        admin_link_to(f, :expert)
      end
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
