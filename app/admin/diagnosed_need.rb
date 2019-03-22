# frozen_string_literal: true

ActiveAdmin.register DiagnosedNeed do
  menu parent: :diagnoses, priority: 1

  ##
  #
  include AdminArchivable

  ## index
  #
  includes :diagnosis, :question, :advisor, :matches, :feedbacks, :company

  scope :diagnosis_completed, default: true
  scope :quo_not_taken_after_3_weeks, group: :abandoned
  scope :taken_not_done_after_3_weeks, group: :abandoned
  scope :rejected, group: :abandoned
  scope :all, group: :all

  index do
    selectable_column
    column :question do |d|
      div admin_link_to(d)
      div admin_attr(d, :content)
    end
    column :advisor
    column :created_at
    column :last_activity_at
    column :status do |d|
      status_tag(*status_tag_status_params(d.status))
      status_tag t('active_admin.archivable.archive_done') if d.archived?
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
      div admin_link_to(d, :feedbacks)
    end

    actions dropdown: true do |d|
      index_row_archive_actions(d)
    end
  end

  statuses = DiagnosedNeed::STATUSES.map { |s| [StatusHelper.status_description(s, :short), s] }
  filter :by_status_in, as: :select, collection: statuses, label: I18n.t('attributes.status')

  filter :archived_in, as: :boolean, label: I18n.t('attributes.archived?')

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
    column :last_activity_at
    column :status_short_description
    column :archived?
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
      row :last_activity_at
      row :archived_at
      row :content
      row(:status) { |d| status_tag(*status_tag_status_params(d.status)) }
      row(:matches) do |d|
        div admin_link_to(d, :matches)
        div admin_link_to(d, :matches, list: true)
      end
    end
  end

  ## Form
  #
  permit_params :diagnosis_id, :question_id, :content

  form do |f|
    f.inputs do
      f.input :question, as: :ajax_select, data: { url: :admin_questions_path, search_fields: [:label] }
      f.input :content
    end

    actions
  end
end
