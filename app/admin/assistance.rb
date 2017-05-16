# frozen_string_literal: true

ActiveAdmin.register Assistance do
  permit_params do
    permitted = %i[answer description]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end
end
