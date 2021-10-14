# frozen_string_literal: true

module Users
  class InvitationsController < Devise::InvitationsController
    before_action :configure_permitted_parameters, only: %i[create update]

    def after_invite_path_for(inviter, invitee = nil)
      new_user_invitation_path
    end

    def after_accept_path_for(inviter)
      tutoriels_path
    end

    def configure_permitted_parameters
      editable_attributes = %i[email full_name role phone_number antenne_id cgu_accepted_at]
      devise_parameter_sanitizer.permit(:invite, keys: editable_attributes)
      devise_parameter_sanitizer.permit(:accept_invitation, keys: editable_attributes)
    end
  end
end
