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
    column(:needs) { |s| needs_description(s) }
    column :alternative
    column :tracking do |s|
      render partial: 'solicitations/tracking', locals: { solicitation: s }
    end
    actions dropdown: true
  end

  preserve_default_filters!

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
