# frozen_string_literal: true

ActiveAdmin.register Skill do
  menu parent: :questions, priority: 2

  ## Index
  #
  includes :theme, :question, :experts
  config.sort_order = 'title_asc'

  index do
    selectable_column
    column(:title) do |a|
      div admin_link_to(a)
      div admin_attr(a, :description)
    end
    column(:theme, sortable: 'themes.interview_sort_order') do |a|
      div admin_link_to(a, :theme)
      div admin_link_to(a, :question)
    end
    column(:experts) do |a|
      admin_link_to(a, :experts)
    end
    actions dropdown: true
  end

  filter :title
  filter :theme, as: :ajax_select, data: { url: :admin_themes_path, search_fields: [:label] }
  filter :question, as: :ajax_select, data: { url: :admin_questions_path, search_fields: [:label] }
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }

  ## CSV
  #
  csv do
    column :title
    column :description
    column :theme
    column :question
    column_count :experts
  end

  ## Show
  #
  show do
    attributes_table do
      row :question
      row :title
      row :description
      row(:experts) { |a| link_to(a.experts.size, admin_experts_path('q[experts_skills_skill_id_eq]': a)) }
    end
  end

  ## Form
  #
  permit_params :question_id, :title, :description
end
