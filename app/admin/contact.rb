# frozen_string_literal: true

ActiveAdmin.register Contact do
  menu parent: :companies, priority: 2
  permit_params :first_name, :last_name, :role, :company_id, :email, :phone_number
end
