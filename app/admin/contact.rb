# frozen_string_literal: true

ActiveAdmin.register Contact do
  menu parent: :companies, priority: 2
  permit_params :full_name, :role, :company_id, :email, :phone_number
  includes :company

  form do |f|
    f.inputs do
      f.input :company, collection: Company.ordered_by_name
      f.input :full_name
      f.input :email
      f.input :phone_number
      f.input :role
    end
  end

  filter :company, collection: -> { Company.ordered_by_name }
  filter :full_name
  filter :email
  filter :phone_number
  filter :role
  filter :created_at
  filter :updated_at
end
