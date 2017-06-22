# frozen_string_literal: true

ActiveAdmin.register Institution do
  menu priority: 6
  permit_params :name, :email, :phone_number
end
