ActiveAdmin.register Solicitation do
  menu priority: 1

  ## Index
  #
  scope :all, default: true

  index do
    selectable_column
    column :created_at
    column :email
    column :phone_number
    column :description
    column(:needs) { |s| needs_description(s) }
    column('alternative') { |s| s.form_info['alternative'] }
    column('tracking info') { |s| s.form_info.select { |k, _| k.start_with?('pk_') } }
    actions dropdown: true
  end

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
