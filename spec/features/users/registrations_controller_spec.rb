# frozen_string_literal: true

require 'rails_helper'

describe 'registrations', type: :feature do
  describe 'profile update' do
    login_user

    before do
      visit edit_user_path

      fill_in id: 'user_full_name', with: 'John Doe'
      fill_in id: 'user_role', with: 'Detective'
      fill_in id: 'user_phone_number', with: '0987654321'

      click_button 'Mettre à jour'
    end

    it 'updates the first name, last name, institution, role and phone number' do
      expect(current_user.reload.full_name).to eq 'John Doe'
      expect(current_user.reload.role).to eq 'Detective'
      expect(current_user.reload.phone_number).to eq '0987654321'
    end
  end

  describe 'password update' do
    login_user

    before do
      visit password_user_path

      fill_in id: 'user_current_password', with: 'yX*4Ubo_xPW!u'
      fill_in id: 'user_password', with: 'new_yX*4Ubo_xPW!u'
      fill_in id: 'user_password_confirmation', with: 'new_yX*4Ubo_xPW!u'

      click_button 'Enregistrer le mot de passe'
    end

    it 'updates the password' do
      expect(current_user.reload).to be_valid_password('new_yX*4Ubo_xPW!u')
    end
  end
end
