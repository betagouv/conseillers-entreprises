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
      div l.logos.truncate(50, separator: ', '), style: 'color: gray'
    end
    column :meta do |l|
      div l.meta_title
      div l.meta_description, style: 'color: gray'
    end
    column :featured_on_home do |l|
      if l.featured_on_home
        div do
          status_tag('yes', :ok)
          span "(position : #{l.home_sort_order})"
        end
        div l.home_title
        div l.home_description, style: 'color: gray'
      else
        status_tag('no', :ok)
      end
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
    end

    attributes_table title: I18n.t("activerecord.models.landing.one") do
      row :meta_title
      row :meta_description
      row :title
      row :subtitle
      row :button
      row :logos
      row :created_at
      row :updated_at
    end

    attributes_table title: I18n.t("activerecord.attributes.landing.featured_on_home") do
      row :featured_on_home
      row :home_title
      row :home_description
      row :home_sort_order
    end

    panel I18n.t('activerecord.attributes.landing.landing_topics') do
      table_for landing.landing_topics.ordered_for_landing do
        column :title
        column :description
      end
    end
  end

  ## Form
  #
  permit_params :slug, :meta_title, :meta_description, :title, :subtitle, :button, :logos, :featured_on_home, :home_title, :home_description, :home_sort_order,
    landing_topics_attributes: [:id, :title, :description, :landing_sort_order, :_destroy]

  form title: :slug do |f|
    f.inputs do
      f.input :slug
    end

    f.inputs I18n.t("activerecord.models.landing.one") do
      f.input :meta_title
      f.input :meta_description
      f.input :title
      f.input :subtitle
      f.input :button
      f.input :logos
    end

    f.inputs I18n.t("activerecord.attributes.landing.featured_on_home") do
      f.input :featured_on_home
      f.input :home_title, :input_html => { :style => 'width:50%' }
      f.input :home_description, :input_html => { :style => 'width:50%', :rows => 3 }
      f.input :home_sort_order, :input_html => { :style => 'width:50%' }
    end

    f.inputs I18n.t('activerecord.attributes.landing.landing_topics') do
      f.has_many :landing_topics, sortable: :landing_sort_order, sortable_start: 1, allow_destroy: true, new_record: true do |a|
        a.input :title,       :input_html => { :style => 'width:50%' }
        a.input :description, :input_html => { :style => 'width:50%', :rows => 3 }
      end
    end

    f.actions
  end
end
