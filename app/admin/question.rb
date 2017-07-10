# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 5

  permit_params do
    permitted = %i[label category_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end

  includes :category
end
