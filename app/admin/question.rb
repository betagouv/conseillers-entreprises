# frozen_string_literal: true

ActiveAdmin.register Question do
  menu priority: 4

  permit_params do
    permitted = %i[label answer_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
