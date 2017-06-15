# frozen_string_literal: true

require 'rails_helper'

describe 'the profile update', type: :feature do
  login_user

  it 'updates the profile' do
    visit edit_user_registration_path

    fill_in id: 'user_first_name', with: 'John'
    fill_in id: 'user_last_name', with: 'Doe'
    fill_in id: 'user_current_password', with: 'password'

    click_button 'Mettre à jour'

    expect(current_user.reload.first_name).to eq 'John'
    expect(current_user.reload.last_name).to eq 'Doe'
  end
end
