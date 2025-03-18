# frozen_string_literal: true

require 'rails_helper'
require 'system_helper'

describe 'passwords', :js do
  describe 'reset password' do
    let!(:user) { create :user, :with_expert, email: 'user@example.com', password: 'P4s55w0rd%ch4ng3', invitation_token: '111222333aaabbb' }

    before do
      create_home_landing
      reset_password_token = user.send(:set_reset_password_token)
      visit edit_user_password_path(reset_password_token: reset_password_token)
      within('#new_user') do
        fill_in 'Nouveau mot de passe', with: 'aaQQwwXXssZZ22##'
        fill_in 'Confirmation du mot de passe', with: 'aaQQwwXXssZZ22##'
        click_on 'Enregistrer le mot de passe'
      end
    end

    it 'resets password' do
      expect(page).to have_css 'h1', text: "Tutoriel"
      expect(page.html).to include 'Votre nouveau mot de passe a bien été enregistré'
      # Impossible de faire fonctionner des tests genre `expect(user.password).to eq('aaQQwwXXssZZ22##')``
    end

    it 'enables re-sign in despite invitation token' do
      expect(page).to have_current_path tutoriels_path, ignore_query: true
      logout :user

      visit new_user_session_path
      user.reload

      within('#new_user') do
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Mot de passe', with: 'aaQQwwXXssZZ22##'
      end
      within '.new_user' do
        click_on 'Accès conseillers', class: 'fr-btn'
      end
      expect(page).to have_content 'Mes besoins'
    end
  end
end
