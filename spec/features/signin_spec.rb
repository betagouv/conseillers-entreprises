# frozen_string_literal: true

require 'rails_helper'

describe 'the signin process', type: :feature do
  before { create :user, email: 'user@example.com', password: 'password' }

  it 'signs me in' do
    visit new_user_session_path
    within('#new_user') do
      fill_in 'Adresse e-mail', with: 'user@example.com'
      fill_in 'Mot de passe', with: 'password'
    end
    click_button 'Se connecter'
    expect(page).to have_content 'Connecté'
  end
end
