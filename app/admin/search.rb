# frozen_string_literal: true

ActiveAdmin.register Search do
  menu parent: :users, priority: 1
  actions :index

  ## Index
  #
  includes :user

  index do
    column :user
    column :created_at
    column :query
    column :label
  end

  filter :user, as: :ajax_select, data: { url: :admin_users_path, search_fields: [:full_name] }
  filter :created_at
  filter :query
  filter :label

  ## CSV
  #
  csv do
    column :user
    column :created_at
    column :query
    column :label
  end
end
