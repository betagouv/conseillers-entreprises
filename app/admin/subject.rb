# frozen_string_literal: true

ActiveAdmin.register Subject do
  menu priority: 5
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
    column :archived? do |s|
      status_tag t('active_admin.archivable.archive_done') if s.archived?
    end
    column(:skills) do |s|
      div admin_link_to(s, :skills)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :archived_in, as: :boolean, label: I18n.t('attributes.archived?')
  filter :label
  filter :theme, as: :ajax_select, data: { url: :admin_themes_path, search_fields: [:label] }

  ## CSV
  #
  csv do
    column :label
    column :theme
    column :interview_sort_order
    column_count :skills
    column :archived?
  end

  ## Show
  #
  show do
    attributes_table do
      row :theme
      row :label
      row :interview_sort_order
      row :archived_at
      row(:skills) { |s| link_to(s.skills.size, admin_skills_path('q[subject_id_eq': s)) }
    end
  end

  ## Form
  #
  permit_params :theme_id, :label, :interview_sort_order

  form do |f|
    f.inputs do
      f.input :theme, as: :ajax_select, data: { url: :admin_themes_path, search_fields: [:label] }
      f.input :label
      f.input :interview_sort_order
    end

    actions
  end
end
