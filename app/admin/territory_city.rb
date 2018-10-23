# frozen_string_literal: true

ActiveAdmin.register TerritoryCity do
  menu parent: :territories, priority: 2
  includes :territory

  filter :territory, collection: -> { Territory.ordered_by_name }
  filter :created_at
  filter :updated_at
end
