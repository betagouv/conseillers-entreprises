# frozen_string_literal: true

ActiveAdmin.register Facility do
  menu parent: :companies, priority: 1
  permit_params :list, :of, :attributes, :on, :model
end
