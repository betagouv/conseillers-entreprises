# frozen_string_literal: true

ActiveAdmin.register Category do
  menu priority: 6
  permit_params :label
end
