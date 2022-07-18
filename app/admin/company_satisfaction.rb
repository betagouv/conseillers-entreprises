# frozen_string_literal: true

ActiveAdmin.register CompanySatisfaction do
  menu parent: :companies, priority: 3

  ## Index
  #
  includes :need, :landing, :solicitation, :subject
  config.sort_order = 'created_at_desc'

  index do
    selectable_column
    column :contacted_by_expert
    column :useful_exchange
    column :comment
    column :need do |s|
      link_to s.need.to_s, diagnosis_path(s.need.diagnosis)
    end
    column :landing do |s|
      admin_link_to(s.landing) || '-'
    end
    column "#{t('activerecord.attributes.solicitation.tracking')}" do |s|
      if s.solicitation&.pk_campaign&.present?
        div "#{t('activerecord.attributes.solicitation.pk_campaign')} : #{link_to_tracked_campaign(s.solicitation)}".html_safe
      end
      if s.solicitation&.pk_kwd&.present?
        div "#{t('activerecord.attributes.solicitation.pk_kwd')} : « #{link_to_tracked_ad(s.solicitation)} »".html_safe
      end
    end

    column :created_at
    actions dropdown: true
  end

  filter :contacted_by_expert
  filter :useful_exchange
  filter :landing, as: :select, collection: -> { Landing.pluck(:slug, :id) }
  filter :subject, collection: -> { Subject.order(:interview_sort_order) }
  filter :facility_regions, collection: -> { Territory.regions.order(:name) }

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
    column(t('activerecord.attributes.solicitation.pk_campaign')) { |s| s.solicitation&.pk_campaign }
    column(t('activerecord.attributes.solicitation.pk_kwd')) { |s| s.solicitation&.pk_kwd }
  end
end
