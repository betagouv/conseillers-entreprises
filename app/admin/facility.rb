# frozen_string_literal: true

ActiveAdmin.register Facility do
  menu parent: :companies, priority: 1
  includes :company
end
