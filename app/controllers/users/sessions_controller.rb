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
  end
end
