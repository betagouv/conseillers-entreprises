# frozen_string_literal: true

require 'rails_helper'

describe 'the profile update', type: :feature do
  before do
    user = create :user, first_name: 'first name', last_name: 'last name', password: 'password'
    login_as user, scope: :user
  end

  it 'updates the profile' do
    visit edit_user_registration_path

    fill_in id: 'user_first_name', with: 'John'
    fill_in id: 'user_last_name', with: 'Doe'
    fill_in id: 'user_current_password', with: 'password'

    click_button 'Update'

    expect(User.first.first_name).to eq 'John'
    expect(User.first.last_name).to eq 'Doe'
  end
end
