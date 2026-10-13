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

  describe 'GET #proconnect_signed_out' do
    before do
      create_home_landing
      request.env['devise.mapping'] = Devise.mappings[:user]
      session['omniauth.pc.id_token'] = 'proconnect-id-token'
      session['omniauth.state'] = 'state-sent-to-proconnect'
    end

    context 'with the state sent to ProConnect' do
      it 'clears the ProConnect data from the session' do
        get :proconnect_signed_out, params: { state: 'state-sent-to-proconnect' }
        expect(session['omniauth.pc.id_token']).to be_nil
        expect(session['omniauth.state']).to be_nil
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_out')
      end
    end

    context 'with another state' do
      it 'leaves the session untouched' do
        get :proconnect_signed_out, params: { state: 'forged-state' }
        expect(session['omniauth.pc.id_token']).to eq 'proconnect-id-token'
        expect(session['omniauth.state']).to eq 'state-sent-to-proconnect'
        expect(response).to redirect_to root_path
        expect(flash[:notice]).to be_nil
      end
    end

    context 'without any state' do
      before { session.delete('omniauth.state') }

      it 'leaves the session untouched' do
        get :proconnect_signed_out
        expect(session['omniauth.pc.id_token']).to eq 'proconnect-id-token'
        expect(response).to redirect_to root_path
      end
    end
  end
end
