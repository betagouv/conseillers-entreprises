ActiveAdmin.register Landing do
  menu parent: :themes, priority: 3

  includes :landing_topics

  ## Index
  #
  index do
    selectable_column
    column :slug do |l|
      link_to l.slug, landing_path(l.slug)
    end
    column :title
    column :subtitle
    column :button
    column :logos do |l|
      l.logos.truncate(50, separator: ', ')
    end
    column :landing_topics do |l|
      l.landing_topics.present? ? l.landing_topics.length : '-'
    end
    actions dropdown: true
  end

  ## Show
  #
  show do
    attributes_table do
      row :slug do |l|
        link_to l.slug, landing_path(l.slug)
      end
      row :title
      row :subtitle
      row :button
      row :logos
      row :created_at
      row :updated_at
    end

    panel LandingTopic.model_name.human do
      table_for landing.landing_topics.ordered_for_landing do
        column :title
        column :description
      end
    end
  end

  ## Form
  #
  permit_params :slug, :title, :subtitle, :button, :logos,
    landing_topics_attributes: [:id, :title, :description, :landing_sort_order, :_destroy]

  form do |f|
    f.inputs do
      f.input :slug
      f.input :title
      f.input :subtitle
      f.input :button
      f.input :logos
    end

    f.inputs do
      f.has_many :landing_topics, sortable: :landing_sort_order, sortable_start: 1, allow_destroy: true, new_record: true do |a|
        a.input :title,       :input_html => { :style => 'width:50%' }
        a.input :description, :input_html => { :style => 'width:50%', :rows => 3 }
      end
    end

    f.actions
  end
end
