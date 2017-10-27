# frozen_string_literal: true

ActiveAdmin.register Company do
  menu priority: 4
  permit_params :name, :siren
end
