ActiveAdmin.register Landing do
  menu parent: :themes, priority: 3

  includes :landing_topics

  ## Index
  #
  index do
    selectable_column
    column :slug do |l|
      div admin_link_to l
    end
    column I18n.t("activerecord.models.landing.one") do |l|
      div link_to l.title, landing_path(l.slug) if l.slug.present?
      div l.subtitle
      div l.button, style: 'color: gray'
      div l.logos&.truncate(50, separator: ', '), style: 'color: gray'
    end
    column :meta do |l|
      div l.meta_title
      div l.meta_description, style: 'color: gray'
    end
    column :landing_topics do |l|
      l.landing_topics.present? ? l.landing_topics.length : '-'
    end
    actions dropdown: true
  end

  ## Show
  #
  show title: :slug do
    attributes_table do
      row :slug do |l|
        div link_to l.slug, landing_path(l.slug) if l.slug.present?
      end
      row :created_at
      row :updated_at
    end

    attributes_table title: I18n.t("activerecord.attributes.landing.featured_on_home") do
      row :home_title
      row :home_description
      row :home_sort_order
    end

    attributes_table title: I18n.t('activerecord.attributes.landing.landing_topics') do
      row :landing_topic_title

      table_for landing.landing_topics.ordered_for_landing do
        column :title
        column :description
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
        row :button
        row :logos
      end

      attributes_table_for landing do
        row :form_title
        row :form_top_message
        row :description_example
        row :form_bottom_message
        row :form_promise_message
        row :thank_you_message
      end
    end
  end

  ## Form
  #
  permit_params :slug,
                :home_title, :home_description, :home_sort_order,
                *Landing::CONTENT_KEYS,
                landing_topics_attributes: [:id, :title, :description, :landing_sort_order, :_destroy]

  form title: :slug do |f|
    f.inputs do
      f.input :slug
    end

    f.inputs I18n.t("activerecord.attributes.landing.featured_on_home") do
      f.input :home_title, :input_html => { :style => 'width:50%' }
      f.input :home_description, :input_html => { :style => 'width:50%', :rows => 3 }
      f.input :home_sort_order, :input_html => { :style => 'width:50%' }
    end

    f.inputs I18n.t('activerecord.attributes.landing.landing_topics') do
      f.input :landing_topic_title, placeholder: t('landings.form.default_landing_topic_title').html_safe

      f.has_many :landing_topics, sortable: :landing_sort_order, sortable_start: 1, allow_destroy: true, new_record: true do |a|
        a.input :title,       :input_html => { :style => 'width:50%' }
        a.input :description, :input_html => { :style => 'width:50%', :rows => 3 }
      end
    end

    panel I18n.t("activerecord.models.landing.one") do
      f.inputs do
        f.input :meta_title
        f.input :meta_description
      end

      f.inputs do
        f.input :title
        f.input :subtitle
        f.input :button
        f.input :logos
      end

      f.inputs do
        f.input :form_title, placeholder: t('landings.form.default_title').html_safe
        f.input :form_top_message
        f.input :description_example, placeholder: t('landings.form.description.default_example').html_safe
        f.input :form_bottom_message
        f.input :form_promise_message, placeholder: t('landings.form.default_promise_message').html_safe
        f.input :thank_you_message, placeholder: t('landings.form.default_thank_you_message').html_safe
      end
    end

    f.actions
  end
end
