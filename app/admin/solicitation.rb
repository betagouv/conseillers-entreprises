ActiveAdmin.register Solicitation do
  menu priority: 7

  ## Index
  #
  scope :all, default: true

  index do
    selectable_column
    column :solicitation do |s|
      div admin_link_to(s)
      div admin_attr(s, :email)
      div admin_attr(s, :phone_number)
      div admin_attr(s, :description).truncate(200, separator: ' ')
    end
    column :created_at
    column :tracking do |s|
      render 'solicitations/tracking', solicitation: s
    end
    column :slug do |s|
      link_to s.slug, landing_path(s.slug) if s.slug
    end
    actions dropdown: true
  end

  ## CSV
  #
  csv do
    column :email
    column :phone_number
    column :description
    column :created_at
    Solicitation::TRACKING_KEYS.each{ |k| column k }
  end

  ## Form
  #
  permit_params :description, :email, :phone_number
  form do |f|
    f.inputs do
      f.input :description
      f.input :email
      f.input :phone_number
    end

    f.actions
  end
end
