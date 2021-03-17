# frozen_string_literal: true

ActiveAdmin.register Need do
  menu parent: :diagnoses, priority: 1

  ## index
  #
  includes :diagnosis, :subject, :advisor, :matches, :feedbacks, :company

  scope :diagnosis_completed
  scope :all, group: :all, default: true

  index do
    selectable_column
    column :subject do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :updated_at
    column :status do |need|
      human_attribute_status_tag need, :status
      status_tag I18n.t('attributes.is_archived') if need.is_archived
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
      div admin_link_to(d, :feedbacks)
    end

    actions dropdown: true do |need|
      if need.is_archived
        item t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, need])
      else
        item t('archivable.archive'), polymorphic_path([:archive, :admin, need])
      end
    end
  end

  filter :status, as: :select, collection: -> { Need.human_attribute_values(:status, raw_values: true).invert.to_a }

  filter :archived_in, as: :boolean, label: I18n.t('attributes.is_archived')

  filter :created_at
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }
  filter :content
  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :experts, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :facility_regions, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }, collection: -> { Territory.deployed_regions.pluck(:name, :id) }

  ## CSV
  #
  csv do
    column :subject
    column :content
    column :advisor
    column :created_at
    column :updated_at
    column(:status) { |need| need.human_attribute_value(:status, context: :short) }
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
      row(:status) { |need| human_attribute_status_tag need, :status }
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  action_item :archive, only: :show, if: -> { !resource.is_archived } do
    link_to t('archivable.archive'), polymorphic_path([:archive, :admin, resource])
  end

  action_item :unarchive, only: :show, if: -> { resource.is_archived } do
    link_to t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, resource])
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
    redirect_back fallback_location: collection_path, notice: t('archivable.archive_done')
  end

  member_action :unarchive do
    resource.unarchive!
    redirect_back fallback_location: collection_path, notice: t('archivable.unarchive_done')
  end

  batch_action(I18n.t('archivable.archive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.archive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('archivable.archive_done')
  end

  batch_action(I18n.t('archivable.unarchive')) do |ids|
    batch_action_collection.find(ids).each do |resource|
      resource.unarchive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('archivable.unarchive_done')
  end
end
