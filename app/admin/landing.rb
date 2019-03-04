ActiveAdmin.register Landing do
  menu parent: :solicitations, priority: 1

  ## Index
  #
  index do
    selectable_column
    column :slug do |l|
      link_to l.slug, landing_path(l.slug)
    end
    column :title
    column :subtitle
    column :button
    actions dropdown: true
  end

  ## Show
  #
  show do
    attributes_table do
      row :slug do |l|
        link_to l.slug, landing_path(l.slug)
      end
      row :title
      row :subtitle
      row :button
      row :created_at
      row :updated_at
    end
  end

  ## Form
  #
  permit_params :slug, :title, :subtitle, :button
  form do |f|
    f.inputs do
      f.input :slug
      f.input :title
      f.input :subtitle
      f.input :button
    end

    f.actions
  end
end
