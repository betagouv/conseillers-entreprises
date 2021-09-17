# frozen_string_literal: true

require 'rails_helper'

describe 'the signin process', type: :feature do
  let!(:user) { create :user, email: 'user@example.com', password: 'yX*4Ubo_xPW!u' }

  before do
    visit new_user_session_path
    within('#new_user') do
      fill_in 'E-mail', with: 'user@example.com'
      fill_in 'Mot de passe', with: 'yX*4Ubo_xPW!u'
    end
  end

  context 'active user' do
    it do
      click_button 'Connexion'

      expect(page.html).to include 'Demandes reçues'
    end
  end
end
