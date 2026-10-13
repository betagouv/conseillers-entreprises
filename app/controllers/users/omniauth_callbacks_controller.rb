module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Session keys written by omniauth-proconnect and not needed once the user is identified
    PROCONNECT_UNUSED_TOKEN_KEYS = %w[omniauth.pc.access_token omniauth.pc.refresh_token].freeze
    # OAuth 2.0 error code returned when the user or the identity provider denies the request (RFC 6749, 4.1.2.1)
    ACCESS_DENIED_ERROR = 'access_denied'

    def proconnect
      auth = request.env['omniauth.auth']
      PROCONNECT_UNUSED_TOKEN_KEYS.each { |key| session.delete(key) }
      user = find_proconnect_user(auth)

      if user.nil?
        redirect_to new_user_session_path, alert: t('.unknown_account')
        return
      end

      if user.invitation_not_accepted?
        redirect_to new_user_session_path, alert: t('devise.failure.invited')
        return
      end

      # ProConnect `sub` is specific to each identity provider: keep the last one used
      user.update_columns(proconnect_uid: auth.uid) if user.proconnect_uid != auth.uid
      sign_in_and_redirect user, event: :authentication
    end

    # Called by OmniAuth for any error raised while talking to ProConnect, at sign in or at sign out
    def failure
      error = request.env['omniauth.error']
      Appsignal.send_error(error) if error && params[:error] != ACCESS_DENIED_ERROR

      if request.path == "#{user_proconnect_omniauth_authorize_path}/logout"
        redirect_to after_sign_out_path_for(resource_name), notice: t('devise.sessions.signed_out')
      else
        redirect_to new_user_session_path, alert: t('.sign_in_failed')
      end
    end

    private

    def find_proconnect_user(auth)
      return if auth.uid.blank?

      users = User.not_deleted
      email = auth.info.email&.downcase
      users.find_by(proconnect_uid: auth.uid) || (users.find_by(email: email) if email.present?)
    end
  end
end
