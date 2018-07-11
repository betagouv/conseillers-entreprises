# frozen_string_literal: true

require 'rails_helper'

describe 'the signin process', type: :feature do
  before { create :user, email: 'user@example.com', password: 'password' }

  it 'signs me in' do
    visit new_user_session_path
    within('#new_user') do
      fill_in 'E-mail', with: 'user@example.com'
      fill_in 'Mot de passe', with: 'password'
    end
    click_button 'Connexion'
    expect(page.html).to include 'Analyses en cours'
  end
end
