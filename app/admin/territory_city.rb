# frozen_string_literal: true

ActiveAdmin.register TerritoryCity do
  menu parent: :territories, priority: 2
  permit_params :territory_id, :city_code
  includes :territory
end
