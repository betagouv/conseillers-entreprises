# frozen_string_literal: true

ActiveAdmin.register Search do
  menu parent: :users, priority: 1
  actions :index
  includes :user

  index do
    id_column
    column :user
    column :query
    column :label
    column :created_at
  end
end
