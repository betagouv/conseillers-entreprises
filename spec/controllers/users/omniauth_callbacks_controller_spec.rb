require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController do
  describe 'GET #proconnect' do
    let(:proconnect_uid) { 'e7a41249-123d-46b7-b362-5f00d3166ea1' }
    let(:proconnect_email) { 'marie.dupont@example.gouv.fr' }

    before do
      create_home_landing
      request.env['devise.mapping'] = Devise.mappings[:user]
      request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'proconnect',
        uid: proconnect_uid,
        info: { email: proconnect_email }
      )
    end

    context 'with a user already linked to this ProConnect account' do
      let!(:user) { create :user, :invitation_accepted, proconnect_uid: proconnect_uid, email: 'other.email@example.gouv.fr' }

      it 'signs the user in' do
        get :proconnect
        expect(controller.current_user).to eq user
      end
    end

    context 'with a user matching the ProConnect email' do
      let!(:user) { create :user, :invitation_accepted, email: proconnect_email }

      it 'signs the user in and links the ProConnect account' do
        get :proconnect
        expect(controller.current_user).to eq user
        expect(user.reload.proconnect_uid).to eq proconnect_uid
      end
    end

    context 'with a user matching the ProConnect email in a different case' do
      let(:proconnect_email) { 'Marie.Dupont@Example.gouv.fr' }
      let!(:user) { create :user, :invitation_accepted, email: 'marie.dupont@example.gouv.fr' }

      it 'signs the user in' do
        get :proconnect
        expect(controller.current_user).to eq user
      end
    end

    context 'with a deleted user linked to this ProConnect account' do
      let!(:user) { create :user, :invitation_accepted, proconnect_uid: proconnect_uid, deleted_at: Time.zone.now }

      it 'does not sign the user in' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'with a user matching the email and another user linked to this ProConnect account' do
      let!(:user) { create :user, :invitation_accepted, email: proconnect_email }
      let!(:linked_user) { create :user, :invitation_accepted, proconnect_uid: proconnect_uid }

      before { allow(Appsignal).to receive(:send_error) }

      it 'signs nobody in, changes no link and reports the conflict' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq I18n.t('users.omniauth_callbacks.failure.sign_in_failed')
        expect(Appsignal).to have_received(:send_error).with(an_instance_of(Users::OmniauthCallbacksController::ProconnectAccountConflict))
        expect(user.reload.proconnect_uid).to be_nil
        expect(linked_user.reload.proconnect_uid).to eq proconnect_uid
      end
    end

    context 'with a user who has not accepted the invitation yet' do
      let!(:user) { create :user, email: proconnect_email }

      before { user.invite! }

      it 'does not sign in nor link the ProConnect account' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq I18n.t('devise.failure.invited')
        expect(user.reload.proconnect_uid).to be_nil
      end
    end

    context 'with a user who has never been invited' do
      let!(:user) { create :user, email: proconnect_email }

      it 'does not sign in nor link the ProConnect account' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq I18n.t('devise.failure.invited')
        expect(user.reload.proconnect_uid).to be_nil
      end
    end

    context 'without ProConnect sub' do
      let(:proconnect_uid) { nil }
      let(:proconnect_email) { nil }

      before { create :user }

      it 'does not sign in and redirects to the sign in page' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'without ProConnect email' do
      let(:proconnect_email) { nil }

      before { create(:user).update_columns(email: nil) }

      it 'does not sign in and redirects to the sign in page' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'with ProConnect tokens stored in the session' do
      let!(:user) { create :user, :invitation_accepted, email: proconnect_email }

      before do
        session['omniauth.pc.access_token'] = 'access-token'
        session['omniauth.pc.refresh_token'] = 'refresh-token'
        session['omniauth.pc.id_token'] = 'id-token'
      end

      it 'keeps only the id token needed for the ProConnect logout' do
        get :proconnect
        expect(session['omniauth.pc.access_token']).to be_nil
        expect(session['omniauth.pc.refresh_token']).to be_nil
        expect(session['omniauth.pc.id_token']).to eq 'id-token'
      end
    end

    context 'without any matching user' do
      it 'does not sign in and redirects to the sign in page' do
        get :proconnect
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to eq I18n.t('users.omniauth_callbacks.proconnect.unknown_account')
      end
    end
  end
end
