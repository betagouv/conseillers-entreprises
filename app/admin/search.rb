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

  filter :user, collection: -> { User.ordered_by_names }
  filter :query
  filter :label
  filter :created_at
end
