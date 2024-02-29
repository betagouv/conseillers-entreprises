# frozen_string_literal: true

ActiveAdmin.register CompanySatisfaction do
  menu parent: :companies, priority: 3

  ## Index
  #
  includes :need, :landing, :solicitation, :subject, :facility
  config.sort_order = 'created_at_desc'

  scope :all, default: true

  index do
    selectable_column
    column :contacted_by_expert
    column :useful_exchange
    column :comment
    column :need do |s|
      link_to s.need.to_s, conseiller_diagnosis_path(s.need.diagnosis)
    end
    column :landing do |s|
      admin_link_to(s.landing) || '-'
    end
    column "#{t('activerecord.attributes.solicitation.tracking')}" do |s|
      if s.solicitation&.campaign.present?
        div "#{t('activerecord.attributes.solicitation.mtm_campaign')} : #{link_to_tracked_campaign(s.solicitation)}".html_safe
      end
      if s.solicitation&.provenance_detail.present?
        div "#{t('activerecord.attributes.solicitation.mtm_kwd')} : « #{link_to_tracked_ad(s.solicitation)} »".html_safe
      end
    end

    column :created_at
    actions dropdown: true
  end

  filter :created_at
  filter :contacted_by_expert
  filter :useful_exchange
  filter :theme, as: :select, collection: -> { Theme.order(:label).pluck(:label, :id) }
  filter :subject, as: :ajax_select, collection: -> { @subjects.pluck(:label, :id) }, data: { url: :admin_subjects_path, search_fields: [:label] }
  filter :done_institutions, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
  filter :facility, as: :ajax_select, data: { url: :admin_facilities_path, search_fields: [:name] }
  filter :solicitation_email_cont
  filter :facility_regions, collection: -> { Territory.regions.order(:name) }
  filter :landing, as: :ajax_select, collection: -> { Landing.not_archived.pluck(:title, :id) }, data: { url: :admin_landings_path, search_fields: [:title] }

  filter :solicitation_mtm_campaign, as: :string
  filter :solicitation_mtm_kwd, as: :string

  controller do
    before_action only: :index do
      @subjects = if params[:q].present? && params[:q][:theme_id_eq].present?
        Theme.find(params[:q][:theme_id_eq]).subjects.not_archived
      else
        Subject.not_archived
      end
    end
  end

  ## CSV
  #
  csv do
    column :id
    column :created_at
    column :contacted_by_expert
    column :useful_exchange
    column :comment
    column(:landing) { |s| s.landing&.slug }
    column(:subject) { |s| s.subject&.slug }
    column(t('activerecord.attributes.solicitation.mtm_campaign')) do |s|
      s.solicitation&.campaign.presence
    end
    column(t('activerecord.attributes.solicitation.mtm_kwd')) do |s|
      s.solicitation&.provenance_detail
    end
  end
end
