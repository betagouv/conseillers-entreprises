# frozen_string_literal: true

module Users
  class InvitationsController < Devise::InvitationsController
    before_action :configure_permitted_parameters, only: %i[create update]

    def create
      super do |user|
        # Automatically approve invited users; we’ll probably get rid of approval altogether.
        user.update_attribute(:is_approved, true)
      end
    end

    def after_invite_path_for(inviter, invitee = nil)
      new_user_invitation_path
    end

    def after_accept_path_for(inviter)
      after_sign_in_path_for(inviter)
    end

    def configure_permitted_parameters
      editable_attributes = %i[email full_name role phone_number antenne_id]
      devise_parameter_sanitizer.permit(:invite, keys: editable_attributes)
      devise_parameter_sanitizer.permit(:accept_invitation, keys: editable_attributes)
    end
  end
end
