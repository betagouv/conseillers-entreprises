# frozen_string_literal: true

require 'rails_helper'

describe 'New Solicitation Feature', type: :feature, js: true do
  before do
    Rails.cache.clear
    create :landing, slug: 'landing'
  end

  describe 'post solicitation' do
    before do
      visit '/entreprise/landing'

      fill_in 'Description', with: 'Ceci est un test'
      fill_in 'SIRET', with: '123 456 789 00010'
      fill_in 'Téléphone', with: '0123456789'
      fill_in 'Email', with: 'user@exemple.com'
      click_button 'Envoyer ma demande'
    end

    it { expect(page).to have_content('Merci') }
  end
end
