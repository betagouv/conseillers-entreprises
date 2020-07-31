ActiveAdmin.register Landing do
  menu parent: :themes, priority: 3

  includes :landing_topics, :landing_options

  controller do
    defaults :finder => :find_by_slug
  end

  ## Index
  #
  index do
    selectable_column
    column :slug do |l|
      div admin_link_to l
    end
    column I18n.t("activerecord.models.landing.one") do |l|
      div admin_link_to l.institution if l.institution.present?
      div link_to l.title, l if l.slug.present?
      div l.subtitle
      div l.logos&.truncate(50, separator: ', '), style: 'color: gray'
    end
    column :meta do |l|
      div l.meta_title
      div l.meta_description, style: 'color: gray'
    end
    column :landing_topics do |l|
      l.landing_topics.present? ? l.landing_topics.length : '-'
    end
    column :landing_options do |l|
      l.landing_options.present? ? l.landing_options.length : '-'
    end
    actions dropdown: true
  end

  ## Show
  #
  show title: :slug do
    attributes_table do
      row :institution
      row :slug do |l|
        div link_to l.slug, l if l.slug.present?
      end
      row :created_at
      row :updated_at
    end

    attributes_table title: I18n.t("activerecord.attributes.landing.featured_on_home") do
      row :home_title
      row :home_description
      row :home_sort_order
      row :emphasis do |l|
        status_tag l.emphasis.to_bool
      end
    end

    panel I18n.t("activerecord.models.landing.one") do
      attributes_table_for landing do
        row :meta_title
        row :meta_description
      end

      attributes_table_for landing do
        row :title
        row :subtitle
        row :logos
        row :custom_css
      end
    end

    attributes_table title: I18n.t('activerecord.attributes.landing.landing_topics') do
      row :message_under_landing_topics do |l|
        l.message_under_landing_topics&.html_safe
      end

      table_for landing.landing_topics.ordered_for_landing do
        column :title
        column :description do |topic|
          topic.description&.html_safe
        end
        column :landing_option_slug
      end
    end

    attributes_table title: I18n.t('activerecord.attributes.landing.landing_options') do
      table_for landing.landing_options.ordered_for_landing do
        column I18n.t("landings.new_solicitation_form.form") do |option|
          link_to option.slug, new_solicitation_landing_path(landing, option)
        end
        column :slug
        column :preselected_subject_slug
        column :preselected_institution_slug
        column :form_title
        column :form_description
        column :description_explanation
        LandingOption::REQUIRED_FIELDS_FLAGS.each do |attr|
          column attr
        end
      end
    end

    attributes_table title: I18n.t("landings.new_solicitation_form.form") do
      row :partner_url
    end
  end

  ## Form
  #
  landing_options_attributes = [
    :id, :slug, :landing_sort_order,
    :preselected_institution_slug, :preselected_subject_slug,
    :_destroy, :form_description, :form_title, :description_explanation,
    *LandingOption::REQUIRED_FIELDS_FLAGS,
  ]
  landing_topics_attributes = [:id, :title, :description, :landing_sort_order, :landing_option_slug, :_destroy]
  permit_params :slug,
                :institution_id,
                :home_title, :home_description, :home_sort_order, :partner_url,
                *Landing::CONTENT_KEYS,
                landing_options_attributes: landing_options_attributes,
                landing_topics_attributes: landing_topics_attributes

  form title: :slug do |f|
    f.inputs do
      f.input :slug
      f.input :institution, as: :ajax_select, data: { url: :admin_institutions_path, search_fields: [:name] }
    end

    f.inputs I18n.t("activerecord.attributes.landing.featured_on_home") do
      f.input :home_title
      f.input :home_description, input_html: { rows: 2 }
      f.input :home_sort_order, input_html: { style: 'width:300px', placeholder: I18n.t('active_admin.landings.home_sort_order_placeholder') }
      f.input :emphasis, as: :boolean
    end

    panel I18n.t("activerecord.models.landing.one") do
      f.inputs do
        f.input :meta_title
        f.input :meta_description
      end

      f.inputs do
        f.input :title
        f.input :subtitle
        f.input :logos
        f.input :custom_css, as: :text, input_html: { style: 'width:70%; font-family:monospace', rows: 10 }
      end
    end

    f.inputs I18n.t('activerecord.attributes.landing.landing_topics') do
      f.input :message_under_landing_topics, as: :text, input_html: { rows: 3 }

      f.has_many :landing_topics, sortable: :landing_sort_order, sortable_start: 1, allow_destroy: true, new_record: true do |t|
        t.input :title, input_html: { style: 'width:70%' }
        t.input :description, input_html: { style: 'width:70%', rows: 10 }
        t.input :landing_option_slug, input_html: { style: 'width:70%' }
      end
    end

    f.inputs I18n.t('activerecord.attributes.landing.landing_options') do
      f.has_many :landing_options, sortable: :landing_sort_order, sortable_start: 1, allow_destroy: true, new_record: true do |o|
        o.input :slug, input_html: { style: 'width:70%' }
        o.input :preselected_subject_slug, input_html: { style: 'width:70%' }, as: :datalist, collection: Subject.pluck(:slug)
        o.input :preselected_institution_slug, input_html: { style: 'width:70%' }, as: :datalist, collection: Institution.pluck(:slug)
        o.input :form_title, input_html: { style: 'width:70%' }
        o.input :form_description, as: :text, input_html: { style: 'width:70%', rows: 10 }
        o.input :description_explanation, as: :text, input_html: { style: 'width:70%', rows: 10 }
        LandingOption::REQUIRED_FIELDS_FLAGS.each do |flag|
          o.input flag
        end
      end
    end

    f.inputs I18n.t("landings.new_solicitation_form.form") do
      f.input :partner_url, placeholder: t('landings.new_solicitation_form.description.partner_url').html_safe
    end

    f.actions
  end
end
