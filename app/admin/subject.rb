# frozen_string_literal: true

ActiveAdmin.register Subject do
  menu parent: :themes, priority: 1
  actions :all, except: :destroy

  ##
  #
  include AdminArchivable

  ## Index
  #
  includes :theme, :skills
  config.sort_order = 'themes.interview_sort_order_asc'

  index do
    selectable_column
    column(:label) do |s|
      div admin_link_to(s)
    end
    column :theme, sortable: 'themes.interview_sort_order'
    column :interview_sort_order
    column :is_archived do |s|
      status_tag t('archivable.archive_done') if s.is_archived
    end
    column :is_support do |d|
      status_tag t('activerecord.attributes.subject.is_support') if d.is_support
    end
    column(:skills) do |s|
      div admin_link_to(s, :skills)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :archived_in, as: :boolean, label: I18n.t('attributes.is_archived')
  filter :is_support
  filter :theme, as: :ajax_select, data: { url: :admin_themes_path, search_fields: [:label] }
  filter :label

  ## CSV
  #
  csv do
    column :label
    column :theme
    column :interview_sort_order
    column_count :skills
    column :is_archived
    column :is_support
    column_count :assistances
  end

  ## Show
  #
  show do
    attributes_table do
      row :theme
      row :label
      row :interview_sort_order
      row :archived_at
      row :is_support
      row(:skills) { |s| link_to(s.skills.size, admin_skills_path('q[subject_id_eq': s)) }
    end
  end

  ## Form
  #
  permit_params :theme_id, :label, :interview_sort_order, :is_support

  form do |f|
    f.inputs do
      f.input :theme, as: :ajax_select, data: { url: :admin_themes_path, search_fields: [:label] }
      f.input :label
      f.input :interview_sort_order
      f.input :is_support
    end

    actions
  end
end
