# frozen_string_literal: true

ActiveAdmin.register Theme do
  menu parent: :questions, priority: 1

  ## Index
  #
  config.sort_order = 'interview_sort_order_asc'
  includes :questions, :skills

  index do
    selectable_column
    column(:label) do |c|
      div admin_link_to(c)
    end
    column :interview_sort_order
    column(:questions) do |c|
      div admin_link_to(c, :questions)
      div admin_link_to(c, :skills)
    end
    actions dropdown: true
  end

  filter :label

  ## CSV
  #
  csv do
    column :label
    column :interview_sort_order
    column_count :questions
    column_count :skills
  end

  ## Show
  #
  show do
    attributes_table do
      row :label
      row :interview_sort_order
      row(:questions) { |q| link_to(q.questions.size, admin_questions_path('q[theme_id_eq]': q)) }
      row(:skills) { |q| link_to(q.skills.size, admin_skills_path('q[question_theme_id_eq]': q)) }
    end
  end

  ## Form
  #
  permit_params :label, :interview_sort_order
end
