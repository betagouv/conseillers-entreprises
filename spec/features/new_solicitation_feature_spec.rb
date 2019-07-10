# frozen_string_literal: true

require 'rails_helper'

describe 'New Solicitation Feature', type: :feature, js: true do
  before do
    create :landing, :featured, slug: 'landing'
  end

  describe 'post solicitation' do
    before do
      visit '/aide/landing'

      fill_in 'Description', with: 'Ceci est un test'
      fill_in 'Téléphone', with: '0123456789'
      fill_in 'Email', with: 'user@exemple.com'
      click_button 'Envoyer ma demande'
    end

    it { expect(page).to have_content('Merci') }
  end
end
