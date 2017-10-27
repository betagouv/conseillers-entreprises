# frozen_string_literal: true

ActiveAdmin.register TerritoryUser do
  menu parent: :territories, priority: 1
  permit_params :territory_id, :user_id
  includes :territory, :user
end
