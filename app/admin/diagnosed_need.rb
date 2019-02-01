# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: :diagnoses, priority: 1

  ## index
  #
  includes :diagnosis, :question, :advisor, :matches, :company

  scope :all, default: true
  scope :unsent
  scope :with_no_one_in_charge
  scope :abandoned
  scope :being_taken_care_of
  scope :done
  scope :archived

  index do
    selectable_column
    column :question do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :status do |d|
      css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[d.status_synthesis.to_sym]
      status_tag d.status_short_description, class: css_class

      status_tag 'archivé' if d.archived_at
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
    end

    actions dropdown: true do |d|
      if d.archived?
        item t('active_admin.diagnosed_needs.unarchive'), unarchive_admin_diagnosed_need_path(d)
      else
        item t('active_admin.diagnosed_needs.archive'), archive_admin_diagnosed_need_path(d)
      end
    end
  end

  filter :created_at
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :question, collection: -> { Question.order(:label) }
  filter :content
  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :question
    column :content
    column :advisor
    column :created_at
    column :status_short_description
    column_count :matches
  end

  ## Show
  #
  show do
    attributes_table do
      row :diagnosis
      row :question
      row :advisor
      row :created_at
      row :archived_at
      row :content
      row :status_description do |d|
        css_class = { quo: '', taking_care: 'warning', done: 'ok', not_for_me: 'error' }[d.status_synthesis.to_sym]
        status_tag d.status_description, class: css_class
      end
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  action_item :archive, only: :show, if: -> { !diagnosed_need.archived? } do
    link_to t('active_admin.diagnosed_needs.archive'), archive_admin_diagnosed_need_path(diagnosed_need)
  end

  action_item :unarchive, only: :show, if: -> { diagnosed_need.archived? }  do
    link_to t('active_admin.diagnosed_needs.unarchive'), unarchive_admin_diagnosed_need_path(diagnosed_need)
  end

  ## Form
  #
  permit_params :diagnosis_id, :question_id, :archived_at, :content

  form do |f|
    f.inputs do
      f.input :question, as: :ajax_select, data: { url: :admin_questions_path, search_fields: [:label] }
      f.input :content
    end

    actions
  end

  ## Actions
  #
  #
  member_action :archive do
    resource.archive!
    redirect_back fallback_location: collection_path, notice: t('active_admin.diagnosed_needs.archive_done')
  end

  member_action :unarchive do
    resource.unarchive!
    redirect_back fallback_location: collection_path, notice: t('active_admin.diagnosed_needs.unarchive_done')
  end

  batch_action I18n.t('active_admin.diagnosed_needs.archive') do |ids|
    batch_action_collection.find(ids).each do |d|
      d.archive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.diagnosed_needs.archive_done')
  end

  batch_action I18n.t('active_admin.diagnosed_needs.unarchive') do |ids|
    batch_action_collection.find(ids).each do |d|
      d.unarchive!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.diagnosed_needs.unarchive_done')
  end
end
