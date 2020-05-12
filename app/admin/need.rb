# frozen_string_literal: true

ActiveAdmin.register Need do
  menu parent: :diagnoses, priority: 1

  ## index
  #
  includes :diagnosis, :subject, :advisor, :matches, :feedbacks, :company

  scope :diagnosis_completed, default: true
  scope :abandoned_quo_not_taken, group: :abandoned
  scope :abandoned_taken_not_done, group: :abandoned
  scope :rejected, group: :abandoned
  scope :all, group: :all

  index do
    selectable_column
    column :subject do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :updated_at
    column :status do |d|
      status_status_tag(d.status)
      status_tag t('activerecord.attributes.need.is_archived') if d.is_archived
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
      div admin_link_to(d, :feedbacks)
    end

    actions dropdown: true do |need|
      if need.is_archived
        item t('active_admin.need.unarchive'), polymorphic_path([:unarchive, :admin, need])
      else
        item t('active_admin.need.archive'), polymorphic_path([:archive, :admin, need])
      end
    end
  end

  statuses = Need::STATUSES.map { |s| [StatusHelper.status_description(s, :short), s] }
  filter :by_status_in, as: :select, collection: statuses, label: I18n.t('attributes.status')

  filter :archived_in, as: :boolean, label: I18n.t('activerecord.attributes.need.is_archived')

  filter :created_at
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }
  filter :content
  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :subject
    column :content
    column :advisor
    column :created_at
    column :updated_at
    column :status_short_description
    column :is_archived
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :diagnosis
      row :subject
      row :advisor
      row :created_at
      row :updated_at
      row :archived_at
      row :content
      row(:status) { |d| status_status_tag(d.status) }
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  action_item :archive, only: :show, if: -> { !resource.is_archived } do
    link_to t('active_admin.need.archive'), polymorphic_path([:archive, :admin, resource])
  end

  action_item :unarchive, only: :show, if: -> { resource.is_archived } do
    link_to t('active_admin.need.unarchive'), polymorphic_path([:unarchive, :admin, resource])
  end

  ## Form
  #
  permit_params :diagnosis_id, :subject_id, :content

  form do |f|
    f.inputs do
      f.input :subject, as: :ajax_select, data: { url: :admin_subjects_path, search_fields: [:label] }
      f.input :content
    end

    actions
  end

  ## Actions
  #
  member_action :archive do
    resource.archive!
    redirect_back fallback_location: collection_path, notice: t('active_admin.need.archive_done')
  end

  member_action :unarchive do
    resource.unarchive!
    redirect_back fallback_location: collection_path, notice: t('active_admin.need.unarchive_done')
  end

  batch_action(I18n.t('active_admin.need.archive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.archive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.need.archive_done')
  end

  batch_action(I18n.t('active_admin.need.unarchive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.unarchive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.need.unarchive_done')
  end
end
