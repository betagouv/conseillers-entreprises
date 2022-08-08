# frozen_string_literal: true

ActiveAdmin.register Match do
  include CsvExportable

  menu parent: :diagnoses, priority: 2

  ## Index
  #
  includes :need, :facility, :company, :related_matches,
           :advisor, :advisor_antenne, :advisor_institution,
           :expert, :expert_antenne, :expert_institution,
           :subject, :theme,
           facility: :commune,
           need: :subject,
           diagnosis: :solicitation

  scope :sent, default: true, group: :all
  scope :all, group: :all
  scope :with_deleted_expert
  scope :to_support

  index do
    selectable_column
    column :match, sortable: :status do |m|
      div admin_link_to(m)
      human_attribute_status_tag m, :status
    end
    column :solicitation_created_at do |m|
      if m.solicitation.present?
        div I18n.l(m.solicitation.created_at, format: :admin)
      end
    end
    column :need, sortable: :created_at do |m|
      div admin_link_to(m, :need)
      div admin_attr(m.facility, :commune)
      div I18n.l(m.created_at, format: :admin)
      human_attribute_status_tag m.need, :status
      status_tag t('attributes.is_archived'), class: :ok if m.need.is_archived
    end
    column :advisor do |m|
      div admin_link_to(m, :advisor)
      div admin_link_to(m, :advisor_antenne)
    end
    column :contacted_expert do |m|
      div admin_link_to(m, :expert)
      div admin_link_to(m, :expert_antenne)
      div link_to(I18n.t('active_admin.matches.need_page'), need_path(m.need))
    end
    column(:subject) do |m|
      div admin_link_to(m, :theme)
      div admin_link_to(m, :subject)
    end

    actions dropdown: true do |match|
      if match.is_archived
        item t('archivable.unarchive'), polymorphic_path([:unarchive, :admin, match])
      else
        item t('archivable.archive'), polymorphic_path([:archive, :admin, match])
      end
    end
  end

  before_action :only => :index do
    @antennes_collection = if params[:q].present? && params[:q][:advisor_institution_id_eq].present?
      Antenne.where(institution_id: params[:q][:advisor_institution_id_eq])
    else
      Antenne.all
    end
  end

  collection = -> { Match.human_attribute_values(:status, raw_values: true, context: :short).invert.to_a }
  filter :status, as: :select, collection: collection, label: I18n.t('attributes.status')
  filter :archived_in, as: :boolean, label: I18n.t('attributes.is_archived')

  filter :updated_at

  filter :solicitation_created_at, as: :date_range
  filter :solicitation_mtm_campaign, as: :string

  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }

  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :expert_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :expert_antenne, as: :ajax_select, collection: -> { @antennes_collection.pluck(:name, :id) },
         data: { url: :admin_antennes_path, search_fields: [:name] }

  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }

  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }
  filter :facility_regions, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }, collection: -> { Territory.deployed_regions.pluck(:name, :id) }

  ## Show
  #
  show do
    attributes_table do
      row(:status) { |m| human_attribute_status_tag m, :status }
      row(:need) do |m|
        human_attribute_status_tag m.need, :status
        div admin_link_to(m, :need)
        div do
          if m.diagnosis.step_completed?
            link_to(I18n.t('active_admin.matches.need_page'), need_path(m.need))
          else
            link_to(I18n.t('active_admin.matches.diagnosis_page'), diagnosis_path(m.diagnosis))
          end
        end
        status_tag t('attributes.is_archived'), class: :ok if m.need.is_archived
      end
      row :created_at
      row :updated_at
      row :archived_at
      row :taken_care_of_at
      row :closed_at
      row :advisor do |m|
        if m.advisor.present?
          div admin_link_to(m, :advisor)
          div admin_link_to(m, :advisor_antenne)
        end
      end
      row :contacted_expert do |m|
        div admin_link_to(m, :expert)
        div admin_link_to(m, :expert_antenne)
      end
      row :subject
    end
  end

  ## Form
  #
  permit_params :expert_id, :subject_id, :status
  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: Match.human_attribute_values(:status).invert
      f.input :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
      themes = Theme.all
      collection = option_groups_from_collection_for_select(themes, :subjects, :label, :id, :label, resource.subject_id)
      f.input :subject, input_html: { :size => 20 }, collection: collection
    end

    f.actions
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
