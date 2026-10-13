require 'rails_helper'

describe 'the ProConnect signin process' do
  let!(:user) { create :user, :with_expert, :invitation_accepted, email: 'user@example.com' }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:proconnect] = OmniAuth::AuthHash.new(
      provider: 'proconnect',
      uid: 'e7a41249-123d-46b7-b362-5f00d3166ea1',
      info: { email: 'user@example.com' }
    )
    create_home_landing
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('PROCONNECT_CLIENT_ID').and_return('proconnect-client-id')
    visit new_user_session_path

  end

  after do
    OmniAuth.config.mock_auth[:proconnect] = nil
    OmniAuth.config.test_mode = false
  end

  it 'signs in with ProConnect' do
    click_on 'S’identifier avec ProConnect'

    expect(page.html).to include 'Mes besoins'
    expect(user.reload.proconnect_uid).to eq 'e7a41249-123d-46b7-b362-5f00d3166ea1'
  end

  context 'when ProConnect raises an error' do
    let(:proconnect_error) { Faraday::ServerError.new('the server responded with status 502') }

    before do
      allow(Appsignal).to receive(:send_error)
      OmniAuth.config.before_callback_phase { |_env| raise proconnect_error }
    end

    after { OmniAuth.config.before_callback_phase = nil }

    it 'reports the error and shows a message without technical details' do
      click_on 'S’identifier avec ProConnect'

      expect(Appsignal).to have_received(:send_error).with(proconnect_error)
      expect(page).to have_current_path new_user_session_path
      expect(page).to have_text I18n.t('users.omniauth_callbacks.failure.sign_in_failed')
      expect(page).to have_no_text '502'
    end
  end

  context 'when the user gives up on ProConnect' do
    before do
      allow(Appsignal).to receive(:send_error)
      OmniAuth.config.test_mode = false
    end

    it 'shows a message without reporting any error' do
      visit user_proconnect_omniauth_callback_path(error: 'access_denied', state: 'returned-state')

      expect(Appsignal).not_to have_received(:send_error)
      expect(page).to have_text I18n.t('users.omniauth_callbacks.failure.sign_in_failed')
    end
  end

  context 'when the ProConnect logout fails' do
    let(:proconnect_error) { Faraday::ConnectionFailed.new('connection refused') }

    before do
      allow(Appsignal).to receive(:send_error)
      OmniAuth.config.test_mode = false
      allow_any_instance_of(OmniAuth::Strategies::Proconnect).to receive(:end_session_uri).and_raise(proconnect_error)
    end

    it 'reports the error and tells the user they are signed out' do
      visit "#{user_proconnect_omniauth_authorize_path}/logout"

      expect(Appsignal).to have_received(:send_error).with(proconnect_error)
      expect(page).to have_text I18n.t('devise.sessions.signed_out')
      expect(page).to have_no_text I18n.t('users.omniauth_callbacks.failure.sign_in_failed')
    end
  end
end
