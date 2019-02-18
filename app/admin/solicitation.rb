ActiveAdmin.register Solicitation do
  menu priority: 1

  ## Index
  #
  scope :all, default: true

  filter :alternative_eq, label: "Alternative"

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
