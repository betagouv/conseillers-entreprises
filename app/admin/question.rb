# frozen_string_literal: true

ActiveAdmin.register Question do
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
    column(:label) do |q|
      div admin_link_to(q)
    end
    column :theme, sortable: 'themes.interview_sort_order'
    column :interview_sort_order
    column :archived? do |d|
      status_tag t('active_admin.archivable.archive_done') if d.archived?
    end
    column(:skills) do |q|
      div admin_link_to(q, :skills)
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
      row(:skills) { |q| link_to(q.skills.size, admin_skills_path('q[question_id_eq]': q)) }
    end
  end

  ## Form
  #
  permit_params :theme_id, :label, :interview_sort_order
end
