# frozen_string_literal: true

require 'rails_helper'

describe 'registrations' do
  before { create(:landing, :home) }

  describe 'profile update' do
    login_user

    before do
      visit edit_user_path

      fill_in id: 'user_full_name', with: 'John Doe'
      fill_in id: 'user_job', with: 'Detective'
      fill_in id: 'user_phone_number', with: '0987654321'

      click_on 'Mettre à jour'
    end

    it 'updates the first name, last name, institution, job and phone number' do
      expect(current_user.reload.full_name).to eq 'John Doe'
      expect(current_user.reload.job).to eq 'Detective'
      expect(current_user.reload.phone_number).to eq '09 87 65 43 21'
    end
  end

  describe 'password update' do
    login_user

    context 'with strong password' do
      before do
        visit password_user_path

        fill_in id: 'user_current_password', with: 'aaQQwwXXssZZ22##'
        fill_in id: 'user_password', with: 'new_aaQQwwXXssZZ22##'
        fill_in id: 'user_password_confirmation', with: 'new_aaQQwwXXssZZ22##'

        click_on 'Enregistrer le mot de passe'
      end

      it 'updates the password' do
        expect(current_user.reload).to be_valid_password('new_aaQQwwXXssZZ22##')
        expect(page).to have_current_path(password_user_path)
      end
    end

    context 'with weak password' do
      before do
        visit password_user_path

        fill_in id: 'user_current_password', with: 'aaQQwwXXssZZ22##'
        fill_in id: 'user_password', with: 'lalala'
        fill_in id: 'user_password_confirmation', with: 'lalala'

        click_on 'Enregistrer le mot de passe'
      end

      it 'updates the password' do
        current_user.reload
        expect(current_user.password).to eq('aaQQwwXXssZZ22##')
        expect(current_user).not_to be_valid_password('lalala')
        # expect(page).to have_current_path(password_user_path)
      end
    end

    # Pour vérifier que la modif des exigences des mdp n'impacte pas les users existants
    context 'with initial weak password' do
      before do
        current_user.update_attribute(:password, 'weakpassword')
        visit password_user_path

        fill_in id: 'user_current_password', with: 'weakpassword'
        fill_in id: 'user_password', with: 'aaQQwwXXssZZ22##'
        fill_in id: 'user_password_confirmation', with: 'aaQQwwXXssZZ22##'

        click_on 'Enregistrer le mot de passe'
      end

      it 'updates the password' do
        expect(current_user.reload).to be_valid_password('aaQQwwXXssZZ22##')
      end
    end
  end
end
