# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 5
  permit_params :category_id, :label
  includes :category
end
