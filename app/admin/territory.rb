# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name

  filter :experts
  filter :name
  filter :created_at
  filter :updated_at
end
