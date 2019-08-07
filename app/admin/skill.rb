# frozen_string_literal: true

ActiveAdmin.register Skill do
  menu parent: :themes, priority: 2

  ## Index
  #
  includes :theme, :subject, :experts
  config.sort_order = 'title_asc'

  index do
    selectable_column
    column(:title) do |a|
      div admin_link_to(a)
      div admin_attr(a, :description)
    end
    column(:theme, sortable: 'themes.interview_sort_order') do |a|
      div admin_link_to(a, :theme)
      div admin_link_to(a, :subject)
    end
    column(:experts) do |a|
      admin_link_to(a, :experts)
    end
    column(:matches) do |a|
      admin_link_to(a, :matches)
    end
    actions dropdown: true
  end

  filter :title
  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }

  ## CSV
  #
  csv do
    column :title
    column :description
    column :theme
    column :subject
    column_count :experts
  end

  ## Show
  #
  show do
    attributes_table do
      row :theme
      row :subject
      row :title
      row :description
    end
    attributes_table do
      row(:experts) { |a| admin_link_to(a, :experts) }
    end
    attributes_table do
      row(:matches) { |a| admin_link_to(a, :matches) }
    end
  end

  ## Form
  #
  permit_params :subject_id, :title, :description

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :subject, as: :select, collection: Subject.archived(false).ordered_for_interview.map{ |s| [s.full_label, s.id] }
      f.input :title, :input_html => { :style => 'width:50%' }
      f.input :description, :input_html => { :style => 'width:50%', :rows => 3 }
    end
    f.actions
  end
end
