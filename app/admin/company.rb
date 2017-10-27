# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 4
  permit_params :name, :siren

  filter :name
  filter :siren
  filter :legal_form_code
  filter :created_at
  filter :updated_at
end
