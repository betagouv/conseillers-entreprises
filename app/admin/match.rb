# frozen_string_literal: true

ActiveAdmin.register Match do
  menu parent: :diagnoses, priority: 2

  ## Index
  #
  includes :need, :diagnosis, :facility, :company, :related_matches,
           :advisor, :advisor_antenne, :expert, :expert_antenne,
           need: :subject

  scope :all, default: true
  scope :with_deleted_expert
  scope :to_support

  index do
    selectable_column
    column :match, sortable: :status do |m|
      div admin_link_to(m)
      status_tag(*status_tag_status_params(m.status))
    end
    column :updated_at
    column :need, sortable: :created_at do |m|
      div admin_link_to(m, :need)
      div I18n.l(m.created_at, format: '%Y-%m-%d %H:%M')
      status_tag(*status_tag_status_params(m.need.status))
    end
    column :advisor do |m|
      div admin_link_to(m, :advisor)
      div admin_link_to(m, :advisor_antenne)
    end
    column :contacted_expert do |m|
      if m.expert.present?
        div admin_link_to(m, :expert)
        div admin_link_to(m, :expert_antenne)
        div link_to('Page Référent', need_path(m.diagnosis, access_token: m.expert.access_token))
      else
        div m.expert_full_role
        status_tag I18n.t('active_admin.matches.deleted'), class: 'error'
      end
    end
    column(:skill) do |m|
      div admin_link_to(m, :theme)
      div admin_link_to(m, :subject)
      div admin_link_to(m, :skill)
    end

    actions dropdown: true
  end

  filter :status

  filter :updated_at

  filter :advisor, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :advisor_antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :advisor_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }

  filter :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
  filter :expert_antenne, as: :ajax_select, data: { url: :admin_antennes_path, search_fields: [:name] }
  filter :expert_institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }

  filter :expert_full_name

  filter :theme, collection: -> { Theme.ordered_for_interview }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }
  filter :skill, as: :ajax_select, data: { url: :admin_skills_path, search_fields: [:title] }

  filter :facility_territories, as: :ajax_select, data: { url: :admin_territories_path, search_fields: [:name] }

  ## CSV
  #
  csv do
    column :id
    column(:need) { |m| m.need_id }
    column :facility
    column :created_at
    column :advisor
    column :advisor_antenne
    column :advisor_institution
    column(:subject) { |m| m.need.subject }
    column(:content) { |m| m.need.content }
    column :expert
    column :expert_antenne
    column :expert_institution
    column :skill
    column(:status) { |m| m.status_short_description }
    column(:status_description) { |m| m.need.status_short_description }
    column :taken_care_of_at
    column :closed_at
    column('Page Référent') { |m| need_url(m.diagnosis, access_token: m.expert.access_token) if m.expert.present? }
  end

  ## Show
  #
  show do
    attributes_table do
      row(:status) { |m| status_tag(*status_tag_status_params(m.status)) }
      row :need
      row :created_at
      row :updated_at
      row :taken_care_of_at
      row :closed_at
      row(:need) { |m| status_tag(*status_tag_status_params(m.need.status)) }
      row :advisor
      row :advisor_antenne
      row :contacted_expert do |m|
        if m.expert.present?
          div admin_link_to(m, :expert)
          div admin_link_to(m, :expert_antenne)
          div link_to('Page Référent', need_path(m.diagnosis, access_token: m.expert.access_token))
        else
          div m.expert_full_role
          status_tag I18n.t('active_admin.matches.deleted'), class: 'error'
        end
      end
      row :skill
    end
  end

  ## Form
  #
  permit_params :expert_id, :skill_id, :status
  form do |f|
    f.inputs do
      f.input :status
      f.input :expert, as: :ajax_select, data: { url: :admin_experts_path, search_fields: [:full_name] }
      subjects = Subject.archived(false).includes(:skills)
      collection = option_groups_from_collection_for_select(subjects, :skills, :label, :id, :title)
      f.input :skill, input_html: { :size => 20 }, collection: collection
    end

    f.actions
  end
end
