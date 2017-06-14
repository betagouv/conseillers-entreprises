# frozen_string_literal: true

ActiveAdmin.register Assistance do
  menu priority: 6

  permit_params do
    permitted = %i[question_id user_id company_id title description]
    permitted << :other if params[:action] == 'create'
    permitted
  end
end
