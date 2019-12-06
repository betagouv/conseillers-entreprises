# frozen_string_literal: true

ActiveAdmin.register Theme do
  menu priority: 6

  ## Index
  #
  config.sort_order = 'interview_sort_order_asc'
  includes :subjects, :institutions

  index do
    selectable_column
    column(:label) do |t|
      div admin_link_to(t)
    end
    column :interview_sort_order
    column(:subjects) do |t|
      div admin_link_to(t, :subjects)
      div admin_link_to(t, :institutions)
    end
    column(:needs) do |t|
      div admin_link_to(t, :needs)
      div admin_link_to(t, :matches)
    end
    actions dropdown: true
  end

  filter :label

  ## CSV
  #
  csv do
    column :label
    column :interview_sort_order
    column_count :subjects
    column_count :institutions_subjects
  end

  ## Show
  #
  show do
    attributes_table do
      row :label
      row :interview_sort_order
      row(:subjects) { |t| admin_link_to(t, :subjects) }
      row(:institutions) { |t| admin_link_to(t, :institutions) }
    end
    attributes_table do
      row(:needs) { |t| admin_link_to(t, :needs) }
      row(:matches) { |t| admin_link_to(t, :matches) }
    end
  end

  ## Form
  #
  permit_params :label, :interview_sort_order
end
