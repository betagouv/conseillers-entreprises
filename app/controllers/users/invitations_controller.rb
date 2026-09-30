module Users
  class InvitationsController < Devise::InvitationsController
    before_action :authenticate_admin!, only: [:new]
    before_action :configure_permitted_parameters, only: %i[create update]

    def after_invite_path_for(inviter, invitee = nil)
      new_user_invitation_path
    end

    def after_accept_path_for(inviter)
      tutoriels_path
    end

    def configure_permitted_parameters
      invite_editable_attributes = %i[email full_name phone_number job antenne_id]
      accept_editable_attributes = %i[full_name phone_number job cgu_accepted_at]
      devise_parameter_sanitizer.permit(:invite, keys: invite_editable_attributes)
      devise_parameter_sanitizer.permit(:accept_invitation, keys: accept_editable_attributes)
    end
  end
end
