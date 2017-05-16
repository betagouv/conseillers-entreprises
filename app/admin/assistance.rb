# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu priority: 4

  permit_params do
    permitted = %i[answer_id description]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
