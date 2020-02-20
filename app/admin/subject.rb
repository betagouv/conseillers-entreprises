# frozen_string_literal: true

ActiveAdmin.register Subject do
  menu parent: :themes, priority: 1
  actions :all, except: :destroy

  ##
  #
  include AdminArchivable

  ## Index
  #
  includes :theme, :institutions_subjects
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
    column(:needs) do |s|
      div admin_link_to(s, :needs)
      div admin_link_to(s, :matches)
    end
    column(:institutions) do |s|
      div admin_link_to(s, :institutions)
      div admin_link_to(s, :experts)
    end
    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  filter :archived_in, as: :boolean, label: I18n.t('attributes.is_archived')
  filter :is_support
  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :label

  ## CSV
  #
  csv do
    column :label
    column :theme
    column :interview_sort_order
    column_count :institutions_subjects
    column :is_archived
    column :is_support
    column_count :institutions
    column_count :experts
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
    end
    attributes_table do
      row(:needs) { |s| admin_link_to(s, :needs) }
      row(:matches) { |s| admin_link_to(s, :matches) }
      row(:institutions) { |s| admin_link_to(s, :institutions) }
      row(:experts) { |s| admin_link_to(s, :experts) }
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

  ## Actions
  #
  action_item :define_as_support, only: :show do
    link_to t('active_admin.subject.define_as_support'), define_as_support_admin_subject_path(resource), method: :put
  end
  member_action :define_as_support, method: :put do
    resource.define_as_support!
    redirect_to resource_path, alert: t('active_admin.subject.done')
  end
end
