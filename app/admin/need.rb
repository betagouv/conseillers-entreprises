# frozen_string_literal: true

ActiveAdmin.register Need do
  menu parent: :diagnoses, priority: 1

  ##
  #
  include AdminArchivable

  ## index
  #
  includes :diagnosis, :subject, :advisor, :matches, :feedbacks, :company

  scope :diagnosis_completed, default: true
  scope :quo_not_taken_after_3_weeks, group: :abandoned
  scope :taken_not_done_after_3_weeks, group: :abandoned
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
    column :last_activity_at
    column :status do |d|
      status_tag(*status_tag_status_params(d.status))
      status_tag t('archivable.archive_done') if d.archived?
    end
    column(:matches) do |d|
      div admin_link_to(d, :matches)
      div admin_link_to(d, :feedbacks)
    end

    actions dropdown: true do |need|
      index_row_archive_actions(need)
      item t('active_admin.need.match_with_support_team'), match_with_support_team_admin_need_path(need)
    end
  end

  statuses = Need::STATUSES.map { |s| [StatusHelper.status_description(s, :short), s] }
  filter :by_status_in, as: :select, collection: statuses, label: I18n.t('attributes.status')

  filter :archived_in, as: :boolean, label: I18n.t('attributes.archived?')

  filter :created_at
  filter :company, as: :ajax_select, data: { url: :admin_companies_path, search_fields: [:name] }
  filter :subject, collection: -> { Subject.order(:label) }
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
      row :subject
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

  action_item :match_with_support_team, only: :show do
    link_to t('active_admin.need.match_with_support_team'), match_with_support_team_admin_need_path(need)
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
  member_action :match_with_support_team do
    resource.create_matches!(current_user.support_expert_skill.id)
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.need.match_with_support_team_done')
  end

  batch_action I18n.t('active_admin.need.match_with_support_team') do |ids|
    batch_action_collection.find(ids).each do |need|
      need.create_matches!(current_user.support_expert_skill.id)
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('active_admin.need.match_with_support_team_done')
  end
end
