# frozen_string_literal: true

ActiveAdmin.register Theme do
  menu priority: 6

  ## Index
  #
  config.sort_order = 'interview_sort_order_asc'
  includes :subjects, :skills

  index do
    selectable_column
    column(:label) do |t|
      div admin_link_to(t)
    end
    column :interview_sort_order
    column(:subjects) do |t|
      div admin_link_to(t, :subjects)
      div admin_link_to(t, :skills)
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
    column_count :skills
  end

  ## Show
  #
  show do
    attributes_table do
      row :label
      row :interview_sort_order
      row(:subjects) { |t| link_to(t.subjects.size, admin_subjects_path('q[theme_id_eq]': t)) }
      row(:skills) { |t| link_to(t.skills.size, admin_skills_path('q[subject_theme_id_eq]': t)) }
    end
  end

  ## Form
  #
  permit_params :label, :interview_sort_order
end
