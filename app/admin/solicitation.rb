ActiveAdmin.register Solicitation do
  menu priority: 7

  ## Index
  #
  scope :all, default: true

  includes :diagnosis, :landing, :institution, :badges, diagnosis: :company

  index do
    selectable_column
    column :solicitation do |s|
      div admin_link_to(s)
      div l(s.created_at, format: '%Y-%m-%d %H:%M')
      unless s.status_in_progress?
        human_attribute_status_tag s, :status
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
      admin_link_to(s.diagnosis)
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
      div admin_attr(s, :requested_help_amount)
      div admin_attr(s, :location)
      hr
      if s.pk_campaign.present?
        div "#{t('activerecord.attributes.solicitation.pk_campaign')} : #{link_to_tracked_campaign(s)}".html_safe
      end
      if s.pk_kwd.present?
        div "#{t('activerecord.attributes.solicitation.pk_kwd')} : « #{link_to_tracked_ad(s)} »".html_safe
      end
      if s.institution.present?
        admin_attr(s, :institution)
      end
    end
  end

  ## Filters
  #
  preserve_default_filters!
  remove_filter :diagnosis  # ActiveAdmin default filters build selects for all the declared model relations.
  remove_filter :matches    # Displaying them can become very expensive, especially if to_s is implemented
  remove_filter :needs      # and uses yet another relation.
  filter :landing, as: :select, collection: -> { Landing.pluck(:title, :slug) }
  filter :status, as: :select, collection: -> { Solicitation.human_attribute_values(:status, raw_values: true).invert.to_a }
  filter :diagnosis_regions, as: :select, collection: -> { Territory.regions.pluck(:name, :id) }

  ## Batch actions
  # Statuses
  Solicitation.statuses.each_key do |status|
    batch_action Solicitation.human_attribute_value(:status, status, context: :action, disable_cast: true) do |ids|
      solicitations = batch_action_collection.where(id: ids)
      solicitations.update(status: status)
      model = Solicitation.model_name.human(count: solicitations.size)
      done = Solicitation.human_attribute_value(:status, status, context: :done, count: solicitations.size)
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
    column :diagnosis
    column(:badges) { |s| s.badges.map(&:to_s).join(",") }
    column(:regions) { |s| s.diagnosis_regions&.pluck(:name).uniq.join(", ") }
    Solicitation.all_past_landing_options_slugs.each do |landing|
      column landing, humanize_name: false do |s|
        s.landing_options_slugs&.include?(landing) ? I18n.t('yes') : ''
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
      row(:status) { human_attribute_status_tag solicitation, :status }
      row :diagnosis
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
      f.input :status, collection: Solicitation.human_attribute_values(:status).invert.to_a
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
