# frozen_string_literal: true

require 'rails_helper'

describe 'registrations', type: :feature do
  describe 'user creation' do
    it 'is made faster thanks to default values' do
      visit new_user_registration_path(default_full_name: 'John')

      expect(find_field('Prénom et nom').value).to eq 'John'

      fill_in id: 'user_full_name', with: 'Joe'

      expect(find_field('Prénom et nom').value).to eq 'Joe'
    end
  end

  describe 'profile update' do
    login_user

    before do
      visit edit_user_registration_path

      fill_in id: 'user_full_name', with: 'John Doe'
      fill_in id: 'user_institution', with: 'CIA'
      fill_in id: 'user_role', with: 'Detective'
      fill_in id: 'user_phone_number', with: '0987654321'
      fill_in id: 'user_current_password', with: 'password'

      click_button 'Mettre à jour'
    end

    it 'updates the first name, last name, institution, role and phone number' do
      expect(current_user.reload.full_name).to eq 'John Doe'
      expect(current_user.reload.institution).to eq 'CIA'
      expect(current_user.reload.role).to eq 'Detective'
      expect(current_user.reload.phone_number).to eq '0987654321'
    end
  end
end
