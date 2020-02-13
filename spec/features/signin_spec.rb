# frozen_string_literal: true

require 'rails_helper'

describe 'the signin process', type: :feature do
  let!(:user) { create :user, email: 'user@example.com', password: 'password' }

  before do
    visit new_user_session_path
    within('#new_user') do
      fill_in 'E-mail', with: 'user@example.com'
      fill_in 'Mot de passe', with: 'password'
    end
  end

  context 'active user' do
    it do
      click_button 'Connexion'

      expect(page.html).to include 'Demandes reçues'
    end
  end

  context 'deactivated user' do
    before { user.deactivate! }

    it do
      click_button 'Connexion'

      expect(page.html).to include 'Votre compte a été désactivé'
    end
  end
end
