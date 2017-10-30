# frozen_string_literal: true

ActiveAdmin.register TerritoryCity do
  menu parent: :territories, priority: 2
  permit_params :territory_id, :city_code
  includes :territory

  form do |f|
    inputs do
      f.input :territory, collection: Territory.ordered_by_name
      f.input :city_code
    end
    actions
  end

  filter :city_code
  filter :territory, collection: -> { Territory.ordered_by_name }
  filter :created_at
  filter :updated_at
end
