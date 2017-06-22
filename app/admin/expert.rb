# frozen_string_literal: true

ActiveAdmin.register Expert do
  menu parent: :institutions, priority: 1
  permit_params :first_name, :last_name, :role, :institution_id, :email, :phone_number
end
