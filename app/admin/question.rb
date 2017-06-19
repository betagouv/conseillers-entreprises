# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 7

  permit_params do
    permitted = %i[label category_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
