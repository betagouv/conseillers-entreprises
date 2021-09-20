# frozen_string_literal: true

module Users
  # Custom RegistrationsController
  ## This overrides some Devise features and adds new actions.
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters, only: %i[update]

    # authenticate_scope! and set_minimum_password_length are defined and use in the superclass
    # If we redefine them with different `only:` conditions, we’ll replace the previous conditions
    # Use local blocks instead of symbols to avoid messing with the callbacks configured in the superclass
    prepend_before_action -> { authenticate_scope! }, only: %i[password antenne]
    prepend_before_action -> { set_minimum_password_length }, only: %i[password]

    layout 'user_tabs', only: %i[edit password antenne update update_password]

    # The paths for Devise are heavily customized, see routes.rb.
    # The show action exists only for /mon_compte to redirect to /mon_compte/informations
    def show
      redirect_to action: :edit
    end

    def update_password
      self.resource = current_user
      resource_updated = resource.update_with_password(account_update_params)
      if resource_updated
        set_flash_message :notice, :updated
        bypass_sign_in resource, scope: resource_name
        redirect_to action: :password
      else
        clean_up_passwords resource
        set_minimum_password_length
        render :password
      end
    end

    # Views for the new actions are in /views/users/registrations;
    # views for actions declared in Devise::RegistrationsController are in /views/devise/registrations.
    def password; end

    def antenne; end

    # Override
    def after_update_path_for(_resource)
      edit_user_path
    end

    def update_resource(resource, params)
      if params.include? 'password'
        resource.update_with_password(params)
      else
        # See also configure_permitted_parameters
        # Users can’t modify their own email.
        resource.update_without_password(params)
      end
    end

    protected

    def configure_permitted_parameters
      editable_attributes = %i[full_name institution role phone_number antenne_id]
      not_editable_attributes = %i[email]
      devise_parameter_sanitizer.permit(:sign_up, keys: editable_attributes, except: not_editable_attributes)
      devise_parameter_sanitizer.permit(:account_update, keys: editable_attributes, except: not_editable_attributes)
    end
  end
end
