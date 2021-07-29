# frozen_string_literal: true

ActiveAdmin.register Subject do
  menu parent: :themes, priority: 1
  actions :all

  ##
  #
  include AdminArchivable

  scope :not_archived, default: true
  scope :is_archived

  ## Index
  #
  includes :theme, :institutions_subjects, :experts, :matches, :needs, :institutions
  config.sort_order = 'interview_sort_order_asc'

  index do
    selectable_column
    column(:label) do |s|
      div admin_link_to(s)
    end
    column :theme, sortable: 'themes.interview_sort_order'
    column :interview_sort_order
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

  sidebar I18n.t('active_admin.subject.copy_experts_title'), only: :show do
    div p I18n.t('active_admin.subject.copy_experts_details')
    form_for :copy_from_other, url: { action: :copy_from_other }, method: :put do |f|
      f.select :subject_to_copy_from, options_from_collection_for_select(Subject.archived(false), :id, :label)

      f.submit I18n.t('active_admin.subject.copy_experts_button'), data: { confirm: I18n.t('active_admin.subject.copy_experts_confirm') }
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

  member_action :copy_from_other, method: :put do
    other = Subject.find(params[:copy_from_other][:subject_to_copy_from])
    resource.copy_experts_from_other(other)
    redirect_to resource_path(resource), alert: I18n.t('active_admin.subject.copy_experts_done')
  end
end
