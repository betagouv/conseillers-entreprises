# frozen_string_literal: true

ActiveAdmin.register Company do
  permit_params :name, :siren, :email, :phone_number
end
