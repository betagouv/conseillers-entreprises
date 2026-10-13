module Users
  class SessionsController < Devise::SessionsController
    # Session keys read by omniauth-proconnect to build the ProConnect end session URL
    PROCONNECT_ID_TOKEN_KEY = 'omniauth.pc.id_token'
    PROCONNECT_STATE_KEY = 'omniauth.state'

    def destroy
      # Devise resets the session on sign out: keep the token to restore it afterwards
      proconnect_id_token = session[PROCONNECT_ID_TOKEN_KEY]

      super do
        if proconnect_id_token.present?
          session[PROCONNECT_ID_TOKEN_KEY] = proconnect_id_token
          session[PROCONNECT_STATE_KEY] = SecureRandom.hex(16)
          redirect_to "#{user_proconnect_omniauth_authorize_path}/logout"
          return
        end
      end
    end

    # Where ProConnect sends the user back once its own session is closed (post_logout_redirect_uri)
    def proconnect_signed_out
      if proconnect_state_valid?
        session.delete(PROCONNECT_ID_TOKEN_KEY)
        session.delete(PROCONNECT_STATE_KEY)
        flash.notice = t('devise.sessions.signed_out')
      end
      redirect_to after_sign_out_path_for(resource_name)
    end

    private

    def proconnect_state_valid?
      proconnect_state = session[PROCONNECT_STATE_KEY]
      proconnect_state.present? && ActiveSupport::SecurityUtils.secure_compare(params[:state].to_s, proconnect_state)
    end
  end
end
