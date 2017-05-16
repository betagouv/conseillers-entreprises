# frozen_string_literal: true

ActiveAdmin.register Answer do
  menu priority: 3

  permit_params do
    permitted = %i[label question_id]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
