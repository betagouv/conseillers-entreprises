require 'rails_helper'

RSpec.describe Users::SessionsController do
  describe 'DELETE #destroy' do
    login_user

    before { create_home_landing }

    context 'when signed in with ProConnect' do
      before { session['omniauth.pc.id_token'] = 'proconnect-id-token' }

      it 'signs out locally then redirects to the ProConnect logout' do
        delete :destroy
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to '/mon_compte/auth/proconnect/logout'
        expect(session['omniauth.pc.id_token']).to eq 'proconnect-id-token'
        expect(session['omniauth.state']).to be_present
      end
    end

    context 'when signed in with a password' do
      it 'signs out and redirects to the default path' do
        delete :destroy
        expect(controller.current_user).to be_nil
        expect(response).not_to redirect_to '/mon_compte/auth/proconnect/logout'
      end
    end
  end
end
