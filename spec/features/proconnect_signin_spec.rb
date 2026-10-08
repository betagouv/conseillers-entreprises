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
end
