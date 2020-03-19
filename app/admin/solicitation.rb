ActiveAdmin.register Solicitation do
  menu priority: 7

  ## Index
  #
  scope :all, default: true

  includes :diagnoses, diagnoses: :company

  index do
    selectable_column
    column :solicitation do |s|
      div admin_link_to(s)
      div l(s.created_at, format: '%Y-%m-%d %H:%M')
      unless s.status_in_progress?
        status_tag Solicitation.human_attribute_name("statuses.#{s.status}"), class: s.status
      end
    end
    column :description do |s|
      div link_to s.slug, landing_path(s.slug) if s.slug
      options = s.selected_options
      if options.present?
        div t('activerecord.attributes.solicitation.selected_options') + ' : ' do
          options.each { |option| status_tag option }.join('')
        end
      end
      blockquote simple_format(s.description&.truncate(20000, separator: ' '))
      if s.diagnoses.size > 0
        div "#{s.diagnoses.human_count} :<br/>".html_safe + admin_link_to(s, :diagnoses, list: true)
      end
    end

    column "#{t('attributes.coordinates')} | #{t('activerecord.attributes.solicitation.tracking')}" do |s|
      div do
        if s.siret.present?
          link_to s.siret, company_path(s.siret)
        else
          t('active_admin.solicitations.no_siret')
        end
      end
      div s.full_name
      div s.normalized_phone_number
      div mail_to(s.email)
      hr
      render 'solicitations/tracking', solicitation: s
      if s.partner_token.present?
        admin_attr(s, :institution)
      end
    end
  end

  ## Filters
  #
  preserve_default_filters!
  remove_filter :diagnoses
  filter :status, as: :select, collection: -> { Solicitation.statuses.map { |status, value| [Solicitation.human_attribute_name("statuses.#{status}"), value] } }
  remove_filter :with_selected_option
  filter :with_selected_option_in, as: :select, label: I18n.t('solicitations.solicitation.selected_options'), collection: -> { LandingOption.all.pluck(:slug) }

  batch_action I18n.t('solicitations.solicitation.cancel') do |ids|
    batch_action_collection.find(ids).each do |solicitation|
      solicitation.status_canceled!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('solicitations.mark_as_canceled.done')
  end

  batch_action I18n.t('solicitations.solicitation.mark_as_processed') do |ids|
    batch_action_collection.find(ids).each do |solicitation|
      solicitation.status_processed!
    end
    redirect_back fallback_location: collection_path, notice: I18n.t('solicitations.mark_as_processed.done')
  end

  ## CSV
  #
  csv do
    column :id
    column :created_at
    column :status
    column :description
    column :siret
    column :full_name
    column :phone_number
    column :email
    column :selected_options do |s|
      s.selected_options.join("\n")
    end
    Solicitation::FORM_INFO_KEYS.each{ |k| column k }
  end

  ## Show
  #
  show title: :to_s do
    panel I18n.t('attributes.description') do
      if solicitation.slug
        div link_to solicitation.slug, landing_path(solicitation.slug)
      end
      blockquote simple_format(solicitation.description)
    end

    attributes_table title: t('attributes.coordinates') do
      row :siret do |s|
        if s.siret.present?
          div link_to s.siret, company_path(s.siret)
        end
      end
      row :full_name
      row :phone_number
      row :email
    end

    attributes_table title: t('activerecord.attributes.solicitation.tracking') do
      row :tracking do |s|
        render 'solicitations/tracking', solicitation: s
      end
      row :institution
    end
  end

  sidebar I18n.t('activerecord.models.solicitation.one'), only: :show do
    attributes_table_for solicitation do
      row :status do
        status_tag Solicitation.human_attribute_name("statuses.#{solicitation.status}"), class: solicitation.status
      end
      row :diagnoses
      row :created_at
      row :updated_at
    end
  end

  ## Form
  #
  permit_params :description, :status, :siret, :full_name, :phone_number, :email
  form do |f|
    f.inputs do
      f.input :description, as: :text
      collection = Solicitation.statuses.map { |status, value| [Solicitation.human_attribute_name("statuses.#{status}"), status] }
      f.input :status, collection: collection
      f.input :siret
      f.input :full_name
      f.input :phone_number
      f.input :email
    end

    f.actions
  end
end
