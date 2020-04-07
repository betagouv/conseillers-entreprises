ActiveAdmin.register Solicitation do
  menu priority: 7

  ## Index
  #
  scope :all, default: true

  includes :diagnoses, :landing, diagnoses: :company

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
      div(admin_link_to(s.landing) || s.landing_slug)
      options_slugs = s.landing_options_slugs
      if options_slugs.present?
        div t('activerecord.attributes.solicitation.landing_options') + ' : ' do
          options_slugs.each { |option| div status_tag option }.join
        end
      end
      blockquote simple_format(s.description&.truncate(20000, separator: ' '))
      if s.diagnoses.size > 0
        div "#{s.diagnoses.human_count} :<br/>".html_safe + admin_link_to(s, :diagnoses, list: true)
      end
    end
    column I18n.t('attributes.badges.other') do |s|
      render 'badges', badges: s.badges
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
      if s.pk_campaign.present?
        div "#{t('activerecord.attributes.solicitation.pk_campaign')} : #{link_to_tracked_campaign(s)}"
      end
      if s.pk_kwd.present?
        div "#{t('activerecord.attributes.solicitation.pk_kwd')} : « #{link_to_tracked_ad(s)} »"
      end
      if s.partner_token.present?
        admin_attr(s, :institution)
      end
    end
  end

  ## Filters
  #
  preserve_default_filters!
  remove_filter :diagnoses
  filter :landing_slug
  filter :status, as: :select, collection: -> { Solicitation.statuses.map { |status, value| [Solicitation.human_attribute_name("statuses.#{status}"), value] } }

  ## Batch actions
  # Statuses
  Solicitation.statuses.keys.each do |status|
    batch_action Solicitation.human_attribute_name("statuses_actions.#{status}") do |ids|
      solicitations = batch_action_collection.where(id: ids)
      solicitations.update(status: status)
      model = Solicitation.model_name.human(count: solicitations.size)
      done = Solicitation.human_attribute_name("statuses_done.#{status}", count: solicitations.size)
      redirect_back fallback_location: collection_path, notice: "#{model} #{done}"
    end
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
    column :options do |s|
      s.landing_options_slugs&.join("\n")
    end
    Solicitation.all_past_landing_options_slugs.each do |landing|
      column landing, humanize_name: false do |s|
        s.landing_options_slugs.include?(landing) ? I18n.t('yes') : ''
      end
    end
    Solicitation::FORM_INFO_KEYS.each{ |k| column k, humanize_name: false }
  end

  ## Show
  #
  show title: :to_s do
    panel I18n.t('attributes.description') do
      div(admin_link_to(solicitation.landing) || solicitation.landing_slug)
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
      row I18n.t('attributes.badges.other') do |s|
        render 'badges', badges: s.badges
      end
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
  permit_params :description, :status, :siret, :full_name, :phone_number, :email, badge_ids: []
  form do |f|
    f.inputs do
      f.input :description, as: :text
      collection = Solicitation.statuses.map { |status, value| [Solicitation.human_attribute_name("statuses.#{status}"), status] }
      f.input :status, collection: collection
      f.input :siret
      f.input :full_name
      f.input :phone_number
      f.input :email
      f.input :badges, collection: Badge.all
    end

    f.actions
  end

  form_options = -> do
    { action: %w[ajouter enlever], badge: Badge.all.map { |b| [b.title, b.id] } }
  end
  batch_action I18n.t('active_admin.badges.add_remove'), form: form_options do |ids, inputs|
    badge = Badge.find(inputs[:badge])
    case inputs[:action]
    when 'ajouter'
      Solicitation.where(id: ids).each { |s| s.badges << badge }
    when 'enlever'
      Solicitation.where(id: ids).each { |s| s.badges.delete(badge) }
    end
    redirect_to collection_path, notice: I18n.t('active_admin.badges.modified', action: inputs[:action].gsub('er', 'é'))
  end
end
