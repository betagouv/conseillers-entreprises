# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 5

  ## Index
  #
  includes :category, :assistances
  config.sort_order = 'label_asc'

  index do
    selectable_column
    column(:label) do |q|
      div admin_link_to(q)
    end
    column :category, sortable: 'categories.interview_sort_order'
    column(:assistances) do |q|
      div admin_link_to(q, :assistances)
    end
    actions dropdown: true
  end

  filter :label
  filter :category, as: :ajax_select, data: { url: :admin_categories_path, search_fields: [:label] }

  ## Show
  #
  show do
    attributes_table do
      row :category
      row :label
      row :interview_sort_order
      row(:assistances) { |q| link_to(q.assistances.size, admin_assistances_path('q[question_id_eq]': q)) }
    end
  end

  ## Form
  #
  permit_params :category_id, :label, :interview_sort_order
end
