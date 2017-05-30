# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters, only: [:update]

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name])
    end
  end
end
