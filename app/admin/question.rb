# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 5
  actions :all, except: :destroy

  ##
  #
  include AdminArchivable

  ## Index
  #
  includes :category, :assistances
  config.sort_order = 'categories.interview_sort_order_asc'

  index do
    selectable_column
    column(:label) do |q|
      div admin_link_to(q)
    end
    column :category, sortable: 'categories.interview_sort_order'
    column :interview_sort_order
    column :archived? do |d|
      status_tag t('active_admin.archivable.archive_done') if d.archived?
    end
    column(:assistances) do |q|
      div admin_link_to(q, :assistances)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :archived_in, as: :boolean, label: I18n.t('attributes.archived?')
  filter :label
  filter :category, as: :ajax_select, data: { url: :admin_categories_path, search_fields: [:label] }

  ## CSV
  #
  csv do
    column :label
    column :category
    column :interview_sort_order
    column_count :assistances
    column :archived?
  end

  ## Show
  #
  show do
    attributes_table do
      row :category
      row :label
      row :interview_sort_order
      row :archived_at
      row(:assistances) { |q| link_to(q.assistances.size, admin_assistances_path('q[question_id_eq]': q)) }
    end
  end

  ## Form
  #
  permit_params :category_id, :label, :interview_sort_order
end
