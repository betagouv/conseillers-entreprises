# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters, only: %i[update]

    def after_update_path_for(_resource)
      profile_path
    end

    protected

    def configure_permitted_parameters
      editable_attributes = %i[full_name institution role phone_number]
      devise_parameter_sanitizer.permit(:sign_up, keys: editable_attributes)
      devise_parameter_sanitizer.permit(:account_update, keys: editable_attributes)
    end
  end
end
